//
//  extension AVCaptureVideoOrientation.swift
//  FotoMail
//
//  Created by Alistef on 20/11/2016.
//  Copyright © 2016 garfromDev. All rights reserved.
//

import Foundation
import AVFoundation

/// Fournis un service pour convertir les enums UIInterfaceOrientation-> AVCaptureVideoOrientation
@objc class OrientationHelper:NSObject{
    @objc class func convertInterfaceOrientationToAVCatureVideoOrientation(ui:UIInterfaceOrientation) -> AVCaptureVideoOrientation{
        switch ui {
        case .landscapeRight:       return .landscapeRight
        case .landscapeLeft:        return .landscapeLeft
        case .portrait:             return .portrait
        case .portraitUpsideDown:   return .portraitUpsideDown
        default:                    return .portrait
        }
    }
    
    @objc class func convertUIInterfaceToUIImageOrientation(_ inter:UIInterfaceOrientation)->UIImageOrientation{
        switch inter {
        case .landscapeRight:       return .right
        case .landscapeLeft:        return .left
        case .portrait:             return .up
        case .portraitUpsideDown:   return .down
        default:                    return .up
        }
        
    }
    
    @objc class func decodeUIInterfaceOrientation(_ or :UIInterfaceOrientation) -> String {
        switch or{
        case .landscapeRight:       return "landscapeRight"
        case .landscapeLeft:        return "landscapeLeft"
        case .portrait:             return "portrait"
        case .portraitUpsideDown:   return "portraitUpsideDown"
        default :                   return ""
        }
    }
    

    @objc class func decodeUIImageOrientation(_ or :UIImageOrientation) -> String {
        switch or{
        case .right:        return "landscapeRight"
        case .left:         return "landscapeLeft"
        case .up:           return "portrait"
        case .down:         return "portraitUpsideDown"
        default :           return ""
        }
    }

}

