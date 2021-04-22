//
//  ViewController.swift
//  YOLO
//
//  Created by Борис Малашенко on 10.03.2021.
//  Copyright © 2021 Pharos Production Inc. All rights reserved.
//

import UIKit
import CoreML
import Vision
import AVFoundation
import Accelerate

class CameraViewController: UIViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var cameraView: UIView!
    
    // MARK: - Variable Declarations
    
    let ssdPredictor = SSDPredictor(Model().model)
    var boundingBoxes: [UIBoundingBox] = []
    var screenHeight: CGFloat?
    var screenWidth: CGFloat?
    var videoHeight: Int32?
    var videoWidth: Int32?
    var imageView = UIImageView()
    var miniImageView = UIImageView()
    
    let videoOutput = AVCaptureVideoDataOutput()
    lazy var captureSession: AVCaptureSession? = {
        guard let backCamera = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: backCamera) else {
            return nil
        }
        
        let dimensions = CMVideoFormatDescriptionGetDimensions(backCamera.activeFormat.formatDescription)
        videoHeight = dimensions.height
        videoWidth = dimensions.width
        
        let captureSession = AVCaptureSession()
        captureSession.sessionPreset = .high
        captureSession.addInput(input)
        
        if captureSession.canAddOutput(videoOutput) {
            let videoOutput = AVCaptureVideoDataOutput()
            videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "MyQueue"))
            captureSession.addOutput(videoOutput)
            
            let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            previewLayer.frame = CGRect(x: view.bounds.minX, y: view.bounds.minY, width: view.bounds.width, height: view.bounds.height)
            // `.resize` allows the camera to fill the screen on the iPhone X.
            previewLayer.videoGravity = .resize
            previewLayer.connection?.videoOrientation = .portrait
            cameraView.layer.addSublayer(previewLayer)
            return captureSession
        }
        return nil
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.isUserInteractionEnabled = true
        
        captureSession?.startRunning()
        screenWidth = view.bounds.width
        screenHeight = view.bounds.height
        for _ in 0 ..< 1 {
            let box = UIBoundingBox()
            box.addToLayer(view.layer)
            boundingBoxes.append(box)
        }
        
        self.view.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(screenShot(sender:)))
        
        self.view.addGestureRecognizer(tapGesture)
        
        
        miniImageView.frame = CGRect(x: 0, y: 0, width: 250, height: 250)
        view.addSubview(miniImageView)
    }
    
    @objc func screenShot(sender: UITapGestureRecognizer) {
        miniImageView.image = imageView.image
        self.miniImageView.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi/2))
        //print(imageView.image?.size.width)
        //print(imageView.image?.size.height)
    }
    
}

extension CameraViewController: CaptureManagerDelegate {
    func processCapturedImage(image: UIImage) {
        self.miniImageView.image = image
    }
}

extension UIView {
    
    // Using a function since `var image` might conflict with an existing variable
    // (like on `UIImageView`)
    func asImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }
}

var i = 0;

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
extension CameraViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        //connection.videoOrientation = AVCaptureVideoOrientation.portrait
        
        
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        
        
        let context = CIContext()
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else { return  }
        
        let image = UIImage(cgImage: cgImage)
        
//        DispatchQueue.main.async {
//            self.imageView.image = image
//        }
        
        ssdPredictor.predict(pixelBuffer) { predictions, error in
            
            guard let predictions = predictions else {
                return
            }
            DispatchQueue.main.async {
                guard let screenWidth = self.screenWidth, let screenHeight = self.screenHeight, let videoWidth = self.videoWidth, let videoHeight =  self.videoHeight else {
                    return
                }
                let topKPredictions = predictions.prefix(self.boundingBoxes.count)
                for (index, prediction) in topKPredictions.enumerated() {
                    print(type(of: prediction))
                    guard let label = prediction.labels.first else {
                        return
                    }
                    
                    print(label.identifier)
                    
                    if label.identifier != "person" {
                        return
                    }
                    
                    let width = screenWidth
                    let height = width * (CGFloat(videoWidth) / CGFloat(videoHeight))
                    let offsetY = (screenHeight - height) / 2
                    let scale = CGAffineTransform.identity.scaledBy(x: width, y: height)
                    let transform = CGAffineTransform(scaleX: 1, y: -1).translatedBy(x: 0, y: -height - offsetY)
                    let rect = prediction.boundingBox.applying(scale).applying(transform)
                    
                    var extraArea: CGFloat = 0
                    let extendedRect = CGRect(x: max(0, rect.minX - extraArea),
                                              y: max(0, rect.minY - extraArea),
                                              width: min(414, rect.maxX + extraArea),
                                              height: min(896, rect.maxY + extraArea))
                    
                    
                    let color = UIColor(red: 36/255, green: 101/255, blue: 255/255, alpha: 1.0)
                    self.boundingBoxes[index].show(frame: extendedRect, label: label.identifier, color: color)
                    
                    extraArea = 0
                    
                    let alphaMinX = max(0, extendedRect.minX - extraArea)
                    let alphaMinY = max(0, extendedRect.minY - extraArea)
                    let alphaMaxX = min(414, extendedRect.maxX + extraArea)
                    let alphaMaxY = min(896, extendedRect.maxY + extraArea)
                    
                    
                    let x = alphaMinY * 1920 / 896
                    let y = (414 - alphaMaxX) * 1080 / 414
                    let w = (alphaMaxY - alphaMinY) * 1920 / 896
                    let h = (414 - alphaMinX) * 1080 / 414
 
                    let otherRect = CGRect(x: x,
                                           y: y,
                                           width: w,
                                           height: h)
                    
                    let imageRef: CGImage = image.cgImage!.cropping(to: otherRect)!

                    
                    let croppedImage: UIImage = UIImage(cgImage: imageRef).rotate(radians: .pi/2)!
                    
                    if  i % 30 == 0 {
                        let inpaintedIamge = InpaintingViewController.segmentAndInpaint(src: croppedImage)!
                        
                        self.boundingBoxes[index].addImage(image: inpaintedIamge.cgImage!)
                    }
                    i += 1
                    
                }
                for index in topKPredictions.count ..< 1 { // 20 {
                    self.boundingBoxes[index].hide()
                }
                
            }
        }
    }
}

extension UIImage {
    func rotate(radians: Float) -> UIImage? {
        var newSize = CGRect(origin: CGPoint.zero, size: self.size).applying(CGAffineTransform(rotationAngle: CGFloat(radians))).size
        // Trim off the extremely small float value to prevent core graphics from rounding it up
        newSize.width = floor(newSize.width)
        newSize.height = floor(newSize.height)

        UIGraphicsBeginImageContextWithOptions(newSize, false, self.scale)
        let context = UIGraphicsGetCurrentContext()!

        // Move origin to middle
        context.translateBy(x: newSize.width/2, y: newSize.height/2)
        // Rotate around middle
        context.rotate(by: CGFloat(radians))
        // Draw the image at its center
        self.draw(in: CGRect(x: -self.size.width/2, y: -self.size.height/2, width: self.size.width, height: self.size.height))

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage
    }
}
