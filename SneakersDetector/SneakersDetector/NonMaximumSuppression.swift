//
//  NonMaximumSuppression.swift
//  SneakersDetector
//
//  Created by Andre Montenegro on 09/05/2018.
//

import Foundation

extension Array where Element == ObjectDetector.Prediction {

    //Start by selecting the prediction with the highest confidence and calculate its IoU (CGRect+ObjectDetection.swift) with the other predictions.
    //Remove (suppress) the predictions that had an IoU under the threshold received as a parameter.
    //Repeat the same process with the reminder predictions until you get an array of the best predictions.
    //You can try a recursive approach for this algorithm.

    func predictionsAfterNMS(threshold: Float) -> [ObjectDetector.Prediction] {

        return []
    }
}

