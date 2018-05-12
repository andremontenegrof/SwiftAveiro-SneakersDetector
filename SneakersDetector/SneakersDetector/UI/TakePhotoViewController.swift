//
//  TakePhotoViewController.swift
//  SneakersDetector
//
//  Created by Andre Montenegro on 15/04/2018.
//

import Foundation
import UIKit

class TakePhotoViewController: UIViewController {

    let objectDetector: ObjectDetector

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var takePhotoButton: UIButton!
    @IBOutlet weak var mainLabel: UILabel!

    init(withObjectDetector objectDetector: ObjectDetector) {

        self.objectDetector = objectDetector

        super.init(nibName: "TakePhotoViewController", bundle: Bundle.main)

        self.objectDetector.delegate = self
    }

    override func viewDidLoad() {

        super.viewDidLoad()

        mainLabel.text = ""
    }

    @IBAction func takePhoto(_ sender: UIButton) {

        self.presentCamera()
    }

    func presentCamera() {

        let imagePickerController = UIImagePickerController()

        imagePickerController.delegate = self
        imagePickerController.sourceType = .camera

        self.present(imagePickerController, animated: false)
    }

    func showBoundingBox(for prediction: ObjectDetector.Prediction) {

        let boundingBoxFrame = self.imageView.frame.subframeWithNormalizedFrame(normalizedFrame: prediction.boundingBox)

        let boundingBoxView = self.boundingBoxView(withFrame: boundingBoxFrame)

        self.imageView.addSubview(boundingBoxView)
    }

    func boundingBoxView(withFrame frame: CGRect) -> UIView{

        let boundingBoxView = UIView(frame: frame)

        boundingBoxView.layer.borderColor = UIColor.green.cgColor
        boundingBoxView.layer.borderWidth = 4
        boundingBoxView.backgroundColor = .clear

        return boundingBoxView
    }

    func resetBoundingBoxes() {

        self.imageView.subviews.forEach { $0.removeFromSuperview() }
    }

    required init?(coder aDecoder: NSCoder) {

        fatalError("init(coder:) has not been implemented")
    }
}

extension TakePhotoViewController: ObjectDetectorDelegate {

    func didReceive(predictions: [ObjectDetector.Prediction]) {

        DispatchQueue.main.async {

            if predictions.isEmpty {

                self.mainLabel.text = "No results found."

            } else {

                self.mainLabel.text = "Highest confidence: \(predictions[0].confidence)"
            }

            predictions.forEach { self.showBoundingBox(for: $0) }
        }
    }

    func didFailPrediction(withError error: Error) {

    }
}

extension TakePhotoViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {

        let image = info[UIImagePickerControllerOriginalImage] as! UIImage

        imageView.image = image

        resetBoundingBoxes()

        DispatchQueue.global(qos: .userInitiated).async {

            self.objectDetector.predict(cgImage: image.cgImage!)
        }

        picker.dismiss(animated:true, completion: nil)
    }
}

