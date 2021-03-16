//
//  MTFilterManager.swift
//  MetalFilters
//
//  Created by Борис Малашенко on 10.03.2021.
//  Copyright © 2021 Pharos Production Inc. All rights reserved.
//

import Foundation
import UIKit
import MetalPetal

class MTFilterManager {
    
    static let shared = MTFilterManager()
    
    var allFilters: [MTFilter.Type] = []
        
    private var context: MTIContext?
    
    var device = MTLCreateSystemDefaultDevice()!
    
    init() {
        context = try? MTIContext(device: MTLCreateSystemDefaultDevice()!)
    }
    
    func generateThumbnailsForImage(_ image: UIImage, with type: MTFilter.Type) -> UIImage? {
        let inputImage = MTIImage(__cgImage: image.cgImage!, options: [.SRGB: false], isOpaque: true)
        let filter = type.init()
        filter.inputImage = inputImage
        if let cgImage = try? context?.makeCGImage(from: filter.outputImage!) {
            return UIImage(cgImage: cgImage)
        }
        return nil
    }
    
    func generate(image: MTIImage) -> UIImage? {
        if let cgImage = try? context?.makeCGImage(from: image) {
            return UIImage(cgImage: cgImage)
        }
        return nil
    }
    
}
