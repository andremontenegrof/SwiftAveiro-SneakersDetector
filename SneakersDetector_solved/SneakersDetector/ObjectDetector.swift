//
//  ObjectDetector.swift
//  SneakersDetector
//
//  Created by Andre Montenegro on 06/04/2018.
//

import Foundation
import Vision
import UIKit

typealias Confidence = Double
typealias CoordinateElement = Double

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

        let labelIndex: Int
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

    init?(model: MLModel) {

        do {

            self.model = model

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

            return nil
        }
    }

    func predict(cgImage: CGImage) {

        self.predict(requestHandler: VNImageRequestHandler(cgImage: cgImage))
    }

    //ask to implement this predict with pixelbuffer
    //ask to use throttler

    func predict(pixelBuffer: CVPixelBuffer) {

        throttler.async(to: predictionQueue, delay: 1.0) {

            self.predict(requestHandler: VNImageRequestHandler(cvPixelBuffer: pixelBuffer))
        }
    }

    fileprivate func predict(requestHandler: VNImageRequestHandler) {

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

    //confidenceThreshold should change according to model precision
    func predictions(from features: [VNCoreMLFeatureValueObservation],
                     confidenceThreshold: Confidence,
                     maxCount: Int) -> [Prediction]? {

        guard let coordinates = features[0].featureValue.multiArrayValue,
            let confidence = features[1].featureValue.multiArrayValue else {

                return nil
        }

        var unorderedPredictions = [Prediction]()

        let boundingBoxesDimensionIndex = 0
        let classesDimensionIndex = 1

        let numberOfBoundingBoxes = confidence.shape[boundingBoxesDimensionIndex].intValue
        let numberOfClasses = confidence.shape[classesDimensionIndex].intValue
        let confidencePointer = UnsafeMutablePointer<Confidence>(OpaquePointer(confidence.dataPointer))
        let coordinatesPointer = UnsafeMutablePointer<Double>(OpaquePointer(coordinates.dataPointer))
        let boxesStride = Int(truncating: coordinates.strides[boundingBoxesDimensionIndex])

        for boxIdx in 0..<numberOfBoundingBoxes {

            var maxConfidence = 0.0
            var maxIndex = 0
            for classIdx in 0..<numberOfClasses {

                let confidence = confidencePointer[boxIdx * numberOfClasses + classIdx]

                if confidence > maxConfidence {

                    maxConfidence = confidence
                    maxIndex = classIdx
                }
            }

            if maxConfidence > confidenceThreshold {

                let x = coordinatesPointer[boxIdx * boxesStride]
                let y = coordinatesPointer[boxIdx * boxesStride + 1]
                let width = coordinatesPointer[boxIdx * boxesStride + 2]
                let height = coordinatesPointer[boxIdx * boxesStride + 3]

                //create the normalized rect with its origin
                let rect = self.rectFromBoundingBoxCoordinates(x: x, y: y, width: width, height: height)

                let prediction = Prediction(labelIndex: maxIndex,
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

extension ObjectDetector {

    ///Transforms the given bounding box coordinates to a CGRect. From the given x and y that correspond to the center of the box, we create a CGRect with the actual origin point of the box.
    func rectFromBoundingBoxCoordinates(x: CoordinateElement,
                                        y: CoordinateElement,
                                        width: CoordinateElement,
                                        height: CoordinateElement) -> CGRect {

        let origin = CGPoint(x: CGFloat(x - width / 2), y: CGFloat(y - height / 2))
        let size = CGSize(width: CGFloat(width), height: CGFloat(height))

        return CGRect(origin: origin, size: size)
    }
}

