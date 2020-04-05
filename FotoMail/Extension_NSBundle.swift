//
//  Extension_NSBundle.swift
//  FotoMail
//
//  Created by Alistef on 06/01/2017.
//  Copyright © 2017 garfromDev. All rights reserved.
//

import UIKit

/// ajoute une variable calculé appName qui retourne le nom de l'application
public extension Bundle {
    var appName : String {
        return Bundle.main.infoDictionary![kCFBundleNameKey as String] as! String
    }
}
