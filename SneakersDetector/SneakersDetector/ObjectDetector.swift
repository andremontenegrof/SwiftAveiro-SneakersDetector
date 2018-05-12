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

typealias ClassIndex = Int

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

        let classIndex: ClassIndex
        let confidence: Confidence
        let boundingBox: CGRect //normalized rect (all coordinates in [0,1])
    }

    weak var delegate: ObjectDetectorDelegate?

    var confidenceThreshold: Confidence = 0.2
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
            let requestCompletionHandler: VNRequestCompletionHandler = { [weak self] request, error in

                if let predictionError = error {

                    print("did fail prediction with error \(predictionError.localizedDescription)")
                    self?.delegate?.didFailPrediction(withError: predictionError)
                }

                //check if this selfInstance is ok
                if let selfInstance = self,
                    let resultFeatures = request.results as? [VNCoreMLFeatureValueObservation],
                    let predictions = self?.predictions(from: resultFeatures,
                                                        confidenceThreshold: selfInstance.confidenceThreshold,
                                                        maxCount: selfInstance.maxNumberOfPredictions) {

                    print(predictions)
                    selfInstance.delegate?.didReceive(predictions: predictions)
                }
            }

            detectionRequest = VNCoreMLRequest(model: visionModel, completionHandler: requestCompletionHandler)
            detectionRequest?.imageCropAndScaleOption = .scaleFill

        } catch {

            print("did fail creating detection request: \(error)")
        }
    }

    func predict(cgImage: CGImage) {

        self.predict(requestHandler: VNImageRequestHandler(cgImage: cgImage))
    }

    func predict(pixelBuffer: CVPixelBuffer) {

        throttler.async(to: predictionQueue, delay: 1.0) {

            self.predict(requestHandler: VNImageRequestHandler(cvPixelBuffer: pixelBuffer))
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

    func predictions(from features: [VNCoreMLFeatureValueObservation],
                     confidenceThreshold: Confidence,
                     maxCount: Int) -> [Prediction]? {

        guard let boxesArray = features[0].featureValue.multiArrayValue,
            let confidencesArray = features[1].featureValue.multiArrayValue else {

                return nil
        }

        var unorderedPredictions = [Prediction]()

        let boxesCount = boxesArray.shape[0].intValue
        let boxesStride = Int(truncating: boxesArray.strides[0])
        let boxesPointer = UnsafePointer<BoxCoordinate>(OpaquePointer(boxesArray.dataPointer))

        let classesCount = confidencesArray.shape[1].intValue
        let confidencesPointer = UnsafePointer<Confidence>(OpaquePointer(confidencesArray.dataPointer))

        for boxIdx in 0..<boxesCount {

            //get the class with the highest confidence
            var maxConfidence = 0.0
            var bestClassIdx = 0
            for classIdx in 0..<classesCount {

                let confidence = confidencesPointer[boxIdx * classesCount + classIdx]

                if confidence > maxConfidence {

                    maxConfidence = confidence
                    bestClassIdx = classIdx
                }
            }

            //create the bounding box
            let x = boxesPointer[boxIdx * boxesStride]
            let y = boxesPointer[boxIdx * boxesStride + 1]
            let width = boxesPointer[boxIdx * boxesStride + 2]
            let height = boxesPointer[boxIdx * boxesStride + 3]

            //create the normalized rect with its origin
            let rect = ObjectDetector.rectFromBoundingBox(x: x, y: y, width: width, height: height)

            //we will only return a prediction if its confidence is > confidenceThreshold
            if maxConfidence > confidenceThreshold {

                let prediction = Prediction(classIndex: bestClassIdx,
                                            confidence: maxConfidence,
                                            boundingBox: rect)

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
    static func rectFromBoundingBox(x: BoxCoordinate,
                                    y: BoxCoordinate,
                                    width: BoxCoordinate,
                                    height: BoxCoordinate) -> CGRect {

        let origin = CGPoint(x: CGFloat(x - width / 2), y: CGFloat(y - height / 2))
        let size = CGSize(width: CGFloat(width), height: CGFloat(height))

        return CGRect(origin: origin, size: size)
    }
}
