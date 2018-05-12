//
//  LiveCameraViewController.swift
//  SneakersDetector
//
//  Created by Andre Montenegro on 15/04/2018.
//

import AVFoundation
import Vision
import UIKit

class LiveCameraViewController: UIViewController {

    @IBOutlet weak var mainLabel: UILabel!
    @IBOutlet weak var cameraView: UIView!

    fileprivate let objectDetector: ObjectDetector

    fileprivate let cameraLayer = AVCaptureVideoPreviewLayer()

    //check if needed:
    fileprivate let visionSequenceHandler = VNSequenceRequestHandler()

    fileprivate enum Constants {

        static let minimumObservationConfidence: VNConfidence = 0.3
    }

    init(withObjectDetector objectDetector: ObjectDetector) {

        self.objectDetector = objectDetector

        super.init(nibName: "LiveCameraViewController", bundle: Bundle.main)

        self.objectDetector.delegate = self
    }

    required init?(coder aDecoder: NSCoder) {

        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {

        super.viewDidLoad()

        self.startLiveCamera()

        self.cameraView?.layer.addSublayer(self.cameraLayer)
    }

    override func viewDidLayoutSubviews() {

        super.viewDidLayoutSubviews()

        self.cameraLayer.frame = self.cameraView?.bounds ?? .zero
    }
}

//MARK: - Object Detection
extension LiveCameraViewController {

    func showBoundingBox(for prediction: ObjectDetector.Prediction) {

        let boundingBoxFrame = self.cameraLayer.frame.subframeWithNormalizedFrame(normalizedFrame: prediction.boundingBox)

        print("self.cameraLayer.frame = \(self.cameraLayer.frame)")
        print("boundingBoxFrame = \(boundingBoxFrame)")

        let boundingBoxView = self.boundingBoxView(withFrame: boundingBoxFrame)

        self.cameraView.addSubview(boundingBoxView)
    }

    func boundingBoxView(withFrame frame: CGRect) -> UIView{

        let boundingBoxView = UIView(frame: frame)

        boundingBoxView.layer.borderColor = UIColor.green.cgColor
        boundingBoxView.layer.borderWidth = 4
        boundingBoxView.backgroundColor = .clear

        return boundingBoxView
    }

    func resetBoundingBoxes() {

        self.cameraView.subviews.forEach { $0.removeFromSuperview() }
    }

    func configureMainLabel(with confidence: Confidence) {

        let confidencePercentage = round(confidence * 100)

        self.mainLabel.text = "Confidence: \(confidencePercentage)%"

        switch confidencePercentage {

        case 80..<100: self.mainLabel.textColor = #colorLiteral(red: 0.2745098174, green: 0.4862745106, blue: 0.1411764771, alpha: 1)
        case 60..<80: self.mainLabel.textColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
        default: self.mainLabel.textColor = #colorLiteral(red: 0.9392530322, green: 0.9048282504, blue: 0.137907505, alpha: 1)
        }
    }
}

//MARK: - AVFoundation

fileprivate extension LiveCameraViewController {

    func startLiveCamera() {

        let session = AVCaptureSession()

        //Preset.photo: An AVCaptureSession preset suitable for high resolution photo quality output.
        session.sessionPreset = AVCaptureSession.Preset.photo

        if let backCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
            let input = try? AVCaptureDeviceInput(device: backCamera) {


            session.addInput(input)
        }

        let liveCameraQueue = DispatchQueue(label: "LiveCameraQueue")

        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: liveCameraQueue)
        session.addOutput(videoOutput)

        session.startRunning()

        self.cameraLayer.session = session
        self.cameraLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
    }
}

//MARK: - Camera Capture
extension LiveCameraViewController: AVCaptureVideoDataOutputSampleBufferDelegate {

    func captureOutput(_ output: AVCaptureOutput,
                       didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {

        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {

            return
        }

        connection.videoOrientation = .portrait

        self.objectDetector.predict(pixelBuffer: pixelBuffer)
    }
}

extension LiveCameraViewController: ObjectDetectorDelegate {

    func didReceive(predictions: [ObjectDetector.Prediction]) {

        DispatchQueue.main.async {

            if predictions.isEmpty {

                self.mainLabel.text = "No results found."
                self.mainLabel.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)

            } else {

                self.configureMainLabel(with: predictions[0].confidence)
            }

            self.resetBoundingBoxes()
            predictions.forEach { self.showBoundingBox(for: $0) }
        }
    }

    func didFailPrediction(withError error: Error) {

    }
}

extension LiveCameraViewController {

    override var shouldAutorotate: Bool {

        return false
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {

        return .portrait
    }
}
