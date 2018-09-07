//
//  UIAlertController + YesNoAlertViewController.swift
//  FotoMail
//
//  Created by Alistef on 17/04/2017.
//  Copyright © 2017 garfromDev. All rights reserved.
//

import UIKit
@available(iOS 9.0, *)
extension UIAlertController {

   class func yesNoAlert( title : String? = "",
                     message : String? = "",
                     yesAction : (() -> Void)? = nil,
                     noAction : (() -> Void)? = nil
        ) -> UIAlertController
    {
        let controller = UIAlertController(title:title,
                                           message : message,
                                           preferredStyle: .alert)
        let yes = UIAlertAction(title:"Yes",
                                style: .default,
                                handler: {(a:UIAlertAction) -> Void in yesAction?()})
        controller.addAction(yes)
        
        let no = UIAlertAction(title:"No",
                                style: .default,
                                handler: {(a:UIAlertAction) -> Void in noAction?()})
        controller.addAction(no)
        
        return controller
    }
 
    
    }
    


