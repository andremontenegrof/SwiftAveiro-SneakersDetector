//
//  MLModelDescription+Utils.swift
//  SneakersDetector
//
//  Created by Andre Montenegro on 06/04/2018.
//

import Foundation
import CoreML

extension MLModel {

    fileprivate enum CustomMetadataKey: String {

        case classes = "classes"
        case nmsThreshold = "non_maximum_suppression_threshold"
    }

    fileprivate enum Constants {

        static let defaultNmsThreshold: Float = 0.5
    }

    var customMetadata: [String: String]? {

        return self.modelDescription.metadata[.creatorDefinedKey] as? [String: String]
    }

    var labels: [String]? {

        return self.customMetadata?[CustomMetadataKey.classes.rawValue]?.components(separatedBy: ",")
    }

    var nmsThreshold: Float {

        guard let thresholdString = self.customMetadata?[CustomMetadataKey.nmsThreshold.rawValue] as String?,
            let threshold = Float(thresholdString) else {

                return Constants.defaultNmsThreshold
        }

        return threshold
    }
}

