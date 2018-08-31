//
//  CameraManager.swift
//  FotoMail
//
//  Created by Alistef on 29/08/2018.
//  Copyright © 2018 garfromDev. All rights reserved.
//

import Foundation
import AVFoundation

/**
 This protocol defines an object that is responsible for:
 - checking athorization to use the camera
 - creating the actual camera device and initialize it on a given view
*/
@objc protocol CameraManager{
    func startCamera(onView view:UIView)->AbstractCameraDevice?
    func checkCameraAuthorization(withCompletion  completionHandler:@escaping (Bool)->())
}

/// AVCaptureDevice is naturally conforming to AbstractCameraDevice
extension AVCaptureDevice:AbstractCameraDevice{
}

/**
    This object interface with AVCaptureDevice class
*/
@objc class DefaultCameraManager:NSObject, CameraManager{
    func startCamera(onView view:UIView)->AbstractCameraDevice? {
        return try? AVCaptureDevice.initCamera(on: view) as AbstractCameraDevice
    }
    
    func checkCameraAuthorization(withCompletion  completionHandler:@escaping(Bool)->()){
        AVCaptureDevice.checkCameraAuthorization(completion: completionHandler)
    }
    
    
}
