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

            //VNCoreMLModel is the Vision object that wraps a CoreML model.
            let visionModel = try VNCoreMLModel(for: model)

            // 2 - Create the detection request by passing the visionModel and self.handleDetection as arguments.
            // The detection request should be a VNCoreMLRequest. Vision has other types of requests used for built-in features such as barcodes or faces detection. However, VNCoreMLRequest is the one to be used when we want to perform predictions in CoreML models. The results are passed to the completionHandler passed in the initialization.

            //detectionRequest = <#initialize here#>
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

    // 3 - Implement predict(requestHandler:). For each image we need to perform the detection request against the passed instance of VNImageRequestHandler.
    //
    //  Each image used for predictions needs to have its associated VNImageRequestHandler. This pattern exists to be possible to perform several Vision executions in the same image and complete once they all return. For example, we could want to detect faces and objects in the same image all at once. However, in your implementation you only need to perform the detectionRequest
    func predict(requestHandler: VNImageRequestHandler) {

        // <#perform here the detectionRequest agains the given requestHandler#>
    }

    func handleDetection(for request: VNRequest, error: Error?) {

        if let predictionError = error {

            print("did fail prediction with error \(predictionError.localizedDescription)")
            self.delegate?.didFailPrediction(withError: predictionError)
        }

        // 4 - Get the results the request object. They should be casted to VNCoreMLFeatureValueObservation.
        // Create the predictions using self.predictions(from:confidenceThreshold:maxCount:) and send them to the ObjectDetectorDelegate.
    }

    func predictions(from features: [VNCoreMLFeatureValueObservation],
                     confidenceThreshold: Confidence,
                     maxCount: Int) -> [Prediction]? {

        guard let boxesArray = features[0].featureValue.multiArrayValue,
            let confidencesArray = features[1].featureValue.multiArrayValue else {

                return nil
        }

        print(boxesArray)
        print(confidencesArray)

        var unorderedPredictions = [Prediction]()

        //here we are using the shape property to fetch
        let confidencesCount = confidencesArray.shape[0].intValue
        let classesCount = confidencesArray.shape[1].intValue
//        let confidencesPointer = UnsafePointer<Confidence>(OpaquePointer(confidencesArray.dataPointer))
        let confidencesPointer = confidencesArray.dataPointer.bindMemory(to: Confidence.self, capacity: confidencesCount)

        // 5 - Use shape property to get the number of boxes
        let boxesCount = boxesArray.shape[0].intValue

        // 6 - Define boxesPointer. Please see definition of confidencesPointer.
        //let boxesPointer =

        // 7 - Use stride property to properly infer the number of elements that compose the box.
        //let boxesStride =

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

            // 8 - After ? and ? you can uncomment the code related to bounding box creation
            //create the bounding box
//            let x = boxesPointer[boxIdx * boxesStride]
//            let y = boxesPointer[boxIdx * boxesStride + 1]
//            let width = boxesPointer[boxIdx * boxesStride + 2]
//            let height = boxesPointer[boxIdx * boxesStride + 3]

            //create the normalized rect with its origin
//            let rect = ObjectDetector.rectFromBoundingBox(x: x, y: y, width: width, height: height)

            //we will only return a prediction if its confidence is > confidenceThreshold
            if maxConfidence > confidenceThreshold {

                // 9 - Define boundingBox with the correct value
                let boundingBox = CGRect.zero

                // 10 - Define confidence with the correct value
                let confidence: Confidence = 0

                let prediction = Prediction(classIndex: bestClassIdx, confidence: confidence, boundingBox: boundingBox)

                unorderedPredictions.append(prediction)
            }
        }

        // 11 - We should sort the unorderedPredictions by confidence before being returning

        // 12 - Return the ordered predictions capped to the maxCount given as argument.

        // 13 - You can try to apply Non-maximum suppression to return just the boxes with the highest confidence for each object. Implement predictionsAfterNMS(threshold:) in NonMaximumSuppresion.swift

        return unorderedPredictions
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
