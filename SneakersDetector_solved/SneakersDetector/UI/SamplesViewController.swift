//
//  SamplesViewController
//  SneakersDetector
//
//  Created by Andre Montenegro on 06/04/2018.
//

import UIKit
import Vision

class SamplesViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var previousButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!

    let objectDetector: ObjectDetector

    fileprivate var currentImageIndex = 0

    fileprivate lazy var imagePaths: [String] = {

        let imagePaths = Bundle.main.paths(forResourcesOfType: ".jpg", inDirectory: nil)

        return imagePaths.sorted()
    }()

    init(withObjectDetector objectDetector: ObjectDetector) {

        self.objectDetector = objectDetector

        super.init(nibName: "SamplesViewController", bundle: Bundle.main)

        self.objectDetector.delegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {

        super.viewDidLoad()

        let cgImage = self.updateImageView(withImageIndex: self.currentImageIndex)!.cgImage

        DispatchQueue.global(qos: .userInitiated).async {

            self.objectDetector.predict(cgImage: cgImage!)
        }
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

    @IBAction func didPressNext(_ sender: UIButton) {

        self.currentImageIndex = self.currentImageIndex < self.imagePaths.count ? self.currentImageIndex + 1 : 0

        let cgImage = self.updateImageView(withImageIndex: self.currentImageIndex)?.cgImage

        DispatchQueue.global(qos: .userInitiated).async {

            self.objectDetector.predict(cgImage: cgImage!)
        }
    }

    @IBAction func didPressPrevious(_ sender: UIButton) {

        self.currentImageIndex = self.currentImageIndex > 0 ? self.currentImageIndex - 1 : self.imagePaths.count - 1

        let cgImage = self.updateImageView(withImageIndex: self.currentImageIndex)?.cgImage

        DispatchQueue.global(qos: .userInitiated).async {

            self.objectDetector.predict(cgImage: cgImage!)
        }
    }

    func updateImageView(withImageIndex imageIndex: Int) -> UIImage? {

        guard imageIndex < self.imagePaths.count else {

            return nil
        }

        let imagePath = self.imagePaths[imageIndex]

        if let image = UIImage(contentsOfFile: imagePath) {

            self.imageView.image = image

            self.resetBoundingBoxes()

            return image

        } else {

            return nil
        }
    }
}

extension SamplesViewController: ObjectDetectorDelegate {

    func didReceive(predictions: [ObjectDetector.Prediction]) {

        DispatchQueue.main.async {

            self.resetBoundingBoxes()

            predictions.forEach { self.showBoundingBox(for: $0) }
        }
    }

    func didFailPrediction(withError error: Error) {

        DispatchQueue.main.async {

            self.resetBoundingBoxes()
        }
    }
}

