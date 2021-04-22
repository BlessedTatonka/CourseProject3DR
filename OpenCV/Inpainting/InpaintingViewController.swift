//
//  ViewController.swift
//  herling-broll-filter
//
//  Created by Борис Малашенко on 10.03.2021.
//  Copyright © 2021 Pharos Production Inc. All rights reserved.
//

import UIKit
import Photos
import Metal
import MetalKit

class InpaintingViewController: UIViewController {
    
    @IBOutlet weak var photoView: UIView!
    @IBOutlet weak var albumView: UIView!
//    fileprivate var scrollView: MTScrollView!
    fileprivate var selectedAsset: PHAsset?
    
    @IBOutlet weak var inImageView: UIImageView!
    @IBOutlet weak var outImageView: UIImageView!
    
    var sourceImg: UIImage!
    var maskImg: UIImage!
    
    private lazy var imagePicker: ImagePicker = {
            let imagePicker = ImagePicker()
            imagePicker.delegate = self
            return imagePicker
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        inImageView.image = UIImage(named: "me.png")!
    }
    
    @IBAction func handlePickerTap(_ sender: Any) {
        imagePicker.photoGalleryAsscessRequest()
    }
    
    @IBAction func applyFilter(_ sender: Any) {
        
    }
    
    @IBAction func handleSegmentTap(_ sender: Any) {
        if let cgImg = inImageView.image!.segmentation(){
            outImageView.image = UIImage(cgImage: cgImg)
        }
    }
    
    @IBAction func handelGrayTap(_ sender: Any) {
        outImageView.image = InpaintingViewController.segmentAndInpaint(src: inImageView.image!)
    }
    
    public static func inpaintWhiteMask(src: UIImage) -> UIImage? {
        return OpenCVWrapper.pixMix(src);
    }
    
    public static func segmentAndInpaint(src: UIImage) -> UIImage? {
        if let cgImg = src.segmentation() {
            return OpenCVWrapper.pixMix(src, andMask: UIImage(cgImage: cgImg), andAlgo: Int32(selectedInpainting));
        }
        
        return nil
    }
    
    public func test() {
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}

extension InpaintingViewController: UIImagePickerControllerDelegate,UINavigationControllerDelegate {
 
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            sourceImg = pickedImage.resize(size: CGSize(width: 1200, height: 1200 * (pickedImage.size.height / pickedImage.size.width)))
        }
 
        picker.dismiss(animated: true, completion: nil)
    }
    
}

extension InpaintingViewController: ImagePickerDelegate {

    func imagePicker(_ imagePicker: ImagePicker, didSelect image: UIImage) {
        inImageView.image = image
        imagePicker.dismiss()
    }

    func cancelButtonDidClick(on imageView: ImagePicker) { imagePicker.dismiss() }
    func imagePicker(_ imagePicker: ImagePicker, grantedAccess: Bool,
                     to sourceType: UIImagePickerController.SourceType) {
        guard grantedAccess else { return }
        imagePicker.present(parent: self, sourceType: sourceType)
    }
}
