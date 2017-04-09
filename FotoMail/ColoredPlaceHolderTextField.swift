//
//  ColoredPlaceHolderTextField.swift
//  FotoMail
//
//  Created by Alistef on 19/08/2016.
//  Copyright © 2016 garfromDev. All rights reserved.
//

import Foundation

@IBDesignable
class ColoredPlaceholderTextField: TitleUITextField {
    @IBInspectable var placeholderColor: UIColor

    required init?(coder aDecoder: NSCoder) {
        placeholderColor = UIColor.red
        super.init(coder: aDecoder)
    }
    
    override func draw(_ rect: CGRect) {
        let attributes = [
            NSForegroundColorAttributeName: self.placeholderColor
        ]
        self.attributedPlaceholder = NSMutableAttributedString(string: self.placeholder ?? "", attributes: attributes)
        super.draw(rect)
    }
}

//@IBDesignable
class TintTextField: TitleUITextField {
    @IBInspectable var placeholderColor: UIColor
    
    var tintedClearImage: UIImage?
    
    required init?(coder aDecoder: NSCoder) {
        placeholderColor = UIColor.red
        super.init(coder: aDecoder)
        setupTintColor()
    }
    
    
    
    override func draw(_ rect: CGRect) {
        let attributes = [
            NSForegroundColorAttributeName: self.placeholderColor
        ]
        self.attributedPlaceholder = NSMutableAttributedString(string: self.placeholder ?? "", attributes: attributes)
        super.draw(rect)
    }
    
    
    func setupTintColor() {
//        clearButtonMode = UITextFieldViewMode.whileEditing
//        borderStyle = UITextBorderStyle.roundedRect
//        layer.cornerRadius = 8.0
//        layer.masksToBounds = true
//        layer.borderColor = tintColor.cgColor
//        layer.borderWidth = 1.5
//        backgroundColor = UIColor.clear
//        textColor = tintColor
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        tintClearImage()
    }
    
    private func tintClearImage() {
        for view in subviews {
            if view is UIButton {
                let button = view as! UIButton
                if let uiImage = button.image(for: .highlighted) {
                    if tintedClearImage == nil {
                        tintedClearImage = tintImage(image: uiImage, color: tintColor)
                    }
                    button.setImage(tintedClearImage, for: .normal)
                    button.setImage(tintedClearImage, for: .highlighted)
                }
            }
        }
    }
}


func tintImage(image: UIImage, color: UIColor) -> UIImage {
    let size = image.size
    
    UIGraphicsBeginImageContextWithOptions(size, false, image.scale)
    let context = UIGraphicsGetCurrentContext()
    image.draw(at: CGPoint(x:0, y:0), blendMode: CGBlendMode.normal, alpha: 1.0)
    
    context!.setFillColor(color.cgColor)
    context!.setBlendMode(CGBlendMode.sourceIn)
    context!.setAlpha(1.0)
    
    let rect = CGRect(origin:CGPoint(x:0, y:0), size:image.size)
    UIGraphicsGetCurrentContext()!.fill(rect)
    let tintedImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return tintedImage!
}
