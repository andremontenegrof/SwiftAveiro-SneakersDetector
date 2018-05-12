//
//  AppDelegate.swift
//  SneakersDetector
//
//  Created by Andre Montenegro on 23/03/2018.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    enum AppMode {

        case staticImages
        case takePhoto
        case liveCamera
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        let model = SneakersDetector_67().model
        let appMode: AppMode = .staticImages

        let objectDetector: ObjectDetector = ObjectDetector(model: model)!

        self.startApp(with: appMode, objectDetector: objectDetector)

        return true
    }

    func startApp(with mode: AppMode, objectDetector: ObjectDetector) {

        let mainViewController: UIViewController

        switch mode {

        case .staticImages:
            mainViewController = SamplesViewController(withObjectDetector: objectDetector)

        case .takePhoto:
            mainViewController = TakePhotoViewController(withObjectDetector: objectDetector)

        case .liveCamera:
            mainViewController = LiveCameraViewController(withObjectDetector: objectDetector)
        }

        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.rootViewController = mainViewController
        self.window?.backgroundColor = .white
        self.window?.makeKeyAndVisible()
    }
}
