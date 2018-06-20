//
//  NonMaximumSuppression.swift
//  SneakersDetector
//
//  Created by Andre Montenegro on 09/05/2018.
//

import Foundation

extension Array where Element == ObjectDetector.Prediction {

    // MARK:- Bonus Step (or Homework) - Implement NMS algorithm
    //The goal of this function is to return the best bounding boxes for each of the objects detected. How can we know if a certain box is detecting a different object from another box? We use the given IoU (Intersection over Union) threshold to differentiate the objects found. If the IoU between two boxes is high, we have a high overlap, which means that the 2 boxes are results for the detection of the same object. In this case we need to discard/suppress the box with the lowest confidence.
    //Imperative instructions for the algorithm:
    //1. Start by selecting the prediction with the highest confidence and calculate its IoU (CGRect+ObjectDetection.swift) with the other predictions.
    //2. Remove (suppress) the predictions that have an IoU under the threshold received as a parameter.
    //3. Repeat the same process with the reminder predictions until you get an array of the best predictions.
    //Note: You can try a recursive approach for this algorithm.


    func predictionsAfterNMS(threshold: Float) -> [ObjectDetector.Prediction] {

        return []
    }
}

