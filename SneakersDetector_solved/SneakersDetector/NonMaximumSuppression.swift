//
//  NonMaximumSuppression.swift
//  SneakersDetector
//
//  Created by Andre Montenegro on 09/05/2018.
//

import Foundation

extension Array where Element == ObjectDetector.Prediction {

    //Recursive version
    func r_predictionsAfterNMS(threshold: Float) -> [ObjectDetector.Prediction] {

        guard let first = self.first else { return [] }

        let remainderElements = self.filter {

            return Float(first.boundingBox.intersectionOverUnion(with: $0.boundingBox)) < threshold
        }

        return [first] + remainderElements.r_predictionsAfterNMS(threshold: threshold)
    }

    //Tweaked from: https://github.com/apple/turicreate/blob/master/userguide/object_detection/advanced-usage.md
    func predictionsAfterNMS(threshold: Float) -> [ObjectDetector.Prediction] {

        var predictions: [ObjectDetector.Prediction] = []

        var keep = [Bool](repeating: true, count: self.count)

        for i in 0..<self.count {

            if keep[i] {

                predictions.append(self[i])

                let bbox1 = self[i].boundingBox

                for j in (i+1)..<self.count {

                    if keep[j] {

                        let bbox2 = self[j].boundingBox

                        if Float(bbox1.intersectionOverUnion(with: bbox2)) > threshold {

                            keep[j] = false
                        }
                    }
                }
            }
        }

        return predictions
    }
}

