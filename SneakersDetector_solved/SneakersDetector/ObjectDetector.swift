//
//  ObjectDetector.swift
//  SneakersDetector
//
//  Created by Andre Montenegro on 06/04/2018.
//

import Foundation
import Vision
import UIKit

//We could have a model outputing Float values instead. Hence the usage of these typealias.
typealias Confidence = Double
typealias BoxCoordinate = Double

protocol ObjectDetectorDelegate: class {

    func didReceive(predictions: [ObjectDetector.Prediction])
    func didFailPrediction(withError error: Error)
}

enum ObjectDetectorError: Error {

    case generic

    var localizedDescription: String {

        switch self {
        case .generic:
            return "Generic Error"
        }
    }
}

class ObjectDetector {

    struct Prediction {

        let confidence: Confidence
        let boundingBox: CGRect //normalized rect (all coordinates in [0,1])
    }

    weak var delegate: ObjectDetectorDelegate?

    var confidenceThreshold: Confidence = 0.6
    var maxNumberOfPredictions = 10

    var detectionRequest: VNCoreMLRequest?

    var predictionQueue = DispatchQueue(label: "prediction.queue", qos: .userInitiated)

    let model: MLModel
    let throttler = Throttler()

    init(model: MLModel) {

        self.model = model

        setupDetectionRequest()
    }

    func setupDetectionRequest() {

        do {

            let visionModel = try VNCoreMLModel(for: model)

            detectionRequest = VNCoreMLRequest(model: visionModel, completionHandler: self.handleDetection)
            detectionRequest?.imageCropAndScaleOption = .scaleFill

        } catch {

            print("did fail creating detection request: \(error)")
        }
    }

    func predict(cgImage: CGImage) {

        predictionQueue.async {

            self.predict(requestHandler: VNImageRequestHandler(cgImage: cgImage))
        }
    }

    ///Executes the request to predict for the given pixelBuffer. A throttlingInterval might be passed to avoid unneeded calls to the model.
    func predict(pixelBuffer: CVPixelBuffer, throttlingInterval: TimeInterval?) {

        if let throttlingInterval = throttlingInterval {

            throttler.async(to: predictionQueue, interval: throttlingInterval) {

                self.predict(requestHandler: VNImageRequestHandler(cvPixelBuffer: pixelBuffer))
            }

        } else {

            predictionQueue.async {

                self.predict(requestHandler: VNImageRequestHandler(cvPixelBuffer: pixelBuffer))
            }
        }
    }
}

//MARK: - Predict
fileprivate extension ObjectDetector {

    func predict(requestHandler: VNImageRequestHandler) {

        guard let detectionRequest = self.detectionRequest else {

            self.delegate?.didFailPrediction(withError: ObjectDetectorError.generic)
            return
        }

        do {

            try requestHandler.perform([detectionRequest])

        } catch {

            self.delegate?.didFailPrediction(withError: ObjectDetectorError.generic)
        }
    }

    func handleDetection(for request: VNRequest, error: Error?) {

        if let predictionError = error {

            print("did fail prediction with error \(predictionError.localizedDescription)")
            self.delegate?.didFailPrediction(withError: predictionError)
        }

        //check if this selfInstance is ok
        if let resultFeatures = request.results as? [VNCoreMLFeatureValueObservation],
            let predictions = self.predictions(from: resultFeatures,
                                                confidenceThreshold: self.confidenceThreshold,
                                                maxCount: self.maxNumberOfPredictions) {

//            print(predictions)
            self.delegate?.didReceive(predictions: predictions)
        }
    }

    func predictions(from features: [VNCoreMLFeatureValueObservation],
                     confidenceThreshold: Confidence,
                     maxCount: Int) -> [Prediction]? {

        guard let boxesArray = features[0].featureValue.multiArrayValue,
            let confidencesArray = features[1].featureValue.multiArrayValue else {

                return nil
        }

         print("Boxes Array: " + String(describing: boxesArray))
//         print("Confidences Array: " + String(describing: confidencesArray))

        var unorderedPredictions = [Prediction]()

        let boxesCount = boxesArray.shape[0].intValue
        let boxesStride = Int(truncating: boxesArray.strides[0])
        let boxesPointer = boxesArray.dataPointer.bindMemory(to: BoxCoordinate.self, capacity: boxesCount)

        let confidencesCount = confidencesArray.shape[0].intValue
        let classesCount = confidencesArray.shape[1].intValue
        let confidencesPointer = confidencesArray.dataPointer.bindMemory(to: Confidence.self, capacity: confidencesCount)

        for boxIdx in 0..<boxesCount {

            //get the class with the highest confidence
            var bestConfidence = 0.0
            var bestClassIdx = 0
            for classIdx in 0..<classesCount {

                let confidence = confidencesPointer[boxIdx * classesCount + classIdx]

                if confidence > bestConfidence {

                    bestConfidence = confidence
                    bestClassIdx = classIdx
                }
            }

            //create the bounding box
            let x = boxesPointer[boxIdx * boxesStride]
            let y = boxesPointer[boxIdx * boxesStride + 1]
            let width = boxesPointer[boxIdx * boxesStride + 2]
            let height = boxesPointer[boxIdx * boxesStride + 3]

            //create the normalized rect with its origin
            let boundingBox = ObjectDetector.rectFromBoxCoordinates(x: x, y: y, width: width, height: height)

            //we will only return a prediction if its confidence is > confidenceThreshold
            if bestConfidence > confidenceThreshold {

                let prediction = Prediction(confidence: bestConfidence, boundingBox: boundingBox)

                unorderedPredictions.append(prediction)
            }
        }

        let orderedPredictions = unorderedPredictions.sorted { $0.confidence > $1.confidence }

        let nmsOrderedPredictions = orderedPredictions.r_predictionsAfterNMS(threshold: self.model.nmsThreshold)

        return Array(nmsOrderedPredictions.prefix(upTo: min(nmsOrderedPredictions.count, maxCount)))
    }
}

//MARK: - Helpers

fileprivate extension ObjectDetector {

    ///Transforms the given bounding box coordinates to a CGRect. From the given x and y that correspond to the center of the box, we create a CGRect with the actual origin point of the box.
    static func rectFromBoxCoordinates(x: BoxCoordinate,
                                       y: BoxCoordinate,
                                       width: BoxCoordinate,
                                       height: BoxCoordinate) -> CGRect {

        let origin = CGPoint(x: CGFloat(x - width / 2), y: CGFloat(y - height / 2))
        let size = CGSize(width: CGFloat(width), height: CGFloat(height))

        return CGRect(origin: origin, size: size)
    }
}
