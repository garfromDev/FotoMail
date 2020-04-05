//
//  UIImage+isEqualToImage.swift
//  FotoMail
//
//  Created by Alistef on 05/05/2017.
//  Copyright © 2017 garfromDev. All rights reserved.
//

import Foundation
import UIKit

public extension UIImage {
    
    func isEqualToImage(image: UIImage) -> Bool {
        let data1: NSData = self.pngData()! as NSData
        let data2: NSData = image.pngData()! as NSData
        return data1.isEqual(data2)
    }
    
}
