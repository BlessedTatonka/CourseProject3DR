//
//  UIBoundingBox.swift
//  YOLO
//
//  Created by Борис Малашенко on 10.03.2021.
//  Copyright © 2021 Pharos Production Inc. All rights reserved.
//

import UIKit


class UIBoundingBox: UIView {
    let shapeLayer: CAShapeLayer
    let textLayer: CATextLayer
    let myLayer: CALayer
    
    
    override init(frame: CGRect) {
        shapeLayer = CAShapeLayer()
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineWidth = 3
        shapeLayer.isHidden = true
        
        textLayer = CATextLayer()
        textLayer.isHidden = true
        textLayer.contentsScale = UIScreen.main.scale
        textLayer.fontSize = 14
        textLayer.font = UIFont.systemFont(ofSize: textLayer.fontSize)
        textLayer.alignmentMode = CATextLayerAlignmentMode.center
        
        myLayer = CALayer()
//        let myImage = UIImage(named: "test.png")?.cgImage
//        myLayer.contents = myImage
//        gradientLayer.colors = [UIColor.black.cgColor,
//                                UIColor.black.cgColor,
//                                UIColor.black.cgColor,
//                                UIColor.black.cgColor]
             
//        myLayer.transform = CATransform3DMakeRotation(CGFloat.pi / 2, 0, 0, 1)
        super.init(frame: frame)
    
        //self.addRectangle()
    }

    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addToLayer(_ parent: CALayer) {
        parent.addSublayer(shapeLayer)
        parent.addSublayer(textLayer)
        parent.addSublayer(myLayer)
    }
    
    func show(frame: CGRect, label: String, color: UIColor, textColor: UIColor = .white) {
        CATransaction.setDisableActions(true)
        
        let path = UIBezierPath(roundedRect: frame, cornerRadius: 6.0)
        shapeLayer.path = path.cgPath
        shapeLayer.strokeColor = color.cgColor
        shapeLayer.isHidden = false
        //
        let label2 = "\(Int(path.bounds.minX)); \(Int(path.bounds.minY)); \(Int(path.bounds.maxX)); \(Int(path.bounds.maxY))"
        textLayer.string = label2
        textLayer.foregroundColor = textColor.cgColor
        textLayer.backgroundColor = color.cgColor
        textLayer.isHidden = false
        
        let attributes = [
            NSAttributedString.Key.font: textLayer.font as Any
        ]
        
        let textRect = label2.boundingRect(with: CGSize(width: 400, height: 100), options: .truncatesLastVisibleLine, attributes: attributes, context: nil)
        let textSize = CGSize(width: textRect.width + 6, height: textRect.height)
        let textOrigin = CGPoint(x: frame.origin.x, y: frame.origin.y - textSize.height - 3)
        textLayer.frame = CGRect(origin: textOrigin, size: textSize)
        
        myLayer.frame = frame
        myLayer.isHidden = false
    }
    
    @objc func handleTap(sender: UITapGestureRecognizer) {
        print("tap")
    }
    
    func hide() {
        shapeLayer.isHidden = true
        textLayer.isHidden = true
        myLayer.isHidden = true
    }
    
    func addImage(image: CGImage) {
        myLayer.contents = image
    }
}

