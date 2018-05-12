//
//  Throttler.swift
//  SneakersDetector
//
//  Created by Andre Montenegro on 11/05/2018.
//

import Foundation

typealias Callback = () -> Void

class Throttler {

    var lastExecutionTime = DispatchTime(uptimeNanoseconds: 1)

    func async(to queue: DispatchQueue, delay: TimeInterval, callback: @escaping Callback) {

        if DispatchTime.now() > lastExecutionTime + DispatchTimeInterval.milliseconds(Int(delay * 1000.0)) {

            queue.async {

                self.lastExecutionTime = DispatchTime.now()

                callback()
            }
        }
    }
}

