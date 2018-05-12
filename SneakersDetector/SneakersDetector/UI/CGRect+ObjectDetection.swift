//
//  ObjectDetector+UI.swift
//  SneakersDetector
//
//  Created by Andre Montenegro on 01/05/2018.
//

import Foundation
import UIKit

extension CGRect {

    func subframeWithNormalizedFrame(normalizedFrame: CGRect) -> CGRect {

        return CGRect(x: normalizedFrame.minX * self.width,
                      y: normalizedFrame.minY * self.height,
                      width: normalizedFrame.width * self.width,
                      height: normalizedFrame.height * self.height)
    }

    public func intersectionOverUnion(with otherRect: CGRect) -> CGFloat {

        let intersection = self.intersection(otherRect)
        let union = self.union(otherRect)

        return (intersection.width * intersection.height) / (union.width * union.height)
    }
}

