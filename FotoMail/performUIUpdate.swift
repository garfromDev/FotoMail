//
//  performUIUpdate.swift
//  FotoMail
//
//  Created by Alistef on 31/08/2018.
//  Copyright © 2018 garfromDev. All rights reserved.
//

import Foundation
@objc public extension Operation{
    static func performUIUpdate(using closure: @escaping () -> Void) {
        // If we are already on the main thread, execute the closure directly
        if Thread.isMainThread {
            closure()
        } else {
            DispatchQueue.main.async(execute: closure)
        }
    }
}
