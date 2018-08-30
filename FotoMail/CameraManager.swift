//
//  CameraManager.swift
//  FotoMail
//
//  Created by Alistef on 29/08/2018.
//  Copyright © 2018 garfromDev. All rights reserved.
//

import Foundation
import AVFoundation

@objc protocol CameraManager{
    func startCamera(onView view:UIView)->AbstractCameraDevice?
    func checkCameraAuthorization(withCompletion  completionHandler:@escaping (Bool)->())
}

extension AVCaptureDevice:AbstractCameraDevice{
}

@objc class DefaultCameraManager:NSObject, CameraManager{
    func startCamera(onView view:UIView)->AbstractCameraDevice? {
        return try? AVCaptureDevice.initCamera(on: view) as AbstractCameraDevice
    }
    
    func checkCameraAuthorization(withCompletion  completionHandler:@escaping(Bool)->()){
        AVCaptureDevice.checkCameraAuthorization(completion: completionHandler)
    }
    
    
}
