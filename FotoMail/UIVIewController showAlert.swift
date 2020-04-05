//
//  UIVIewController showAlert.swift
//  FotoMail
//
//  Created by Alistef on 07/09/2018.
//  Copyright © 2018 garfromDev. All rights reserved.
//

import Foundation

extension UIViewController {
    /**
     Display an alert with OK and cancel button
     You must provide at least a message, action are void by default
     Use showAlert() if needed only to dispaly alert with OK button without action
     */
    @objc public func showOkCancelAlert(title : String = "",
                           message: String,
                           yesAction: @escaping ()->() = {},
                           cancelAction:@escaping()->() = {}){
        let alrt = UIAlertController(title: title,
                                     message: message,
                                     preferredStyle: .alert)
        alrt.addAction(UIAlertAction(title: "OK",
                                     style: .default,
                                     handler: { alrt in
                                        yesAction()
        }
        ))
        alrt.addAction(UIAlertAction(title: "Cancel", style: .destructive,
                                     handler: { alrt in
                                        cancelAction()
        }
        ))
        
        self.present(alrt, animated: true)
        
    }
    
    /**
     Display a simple alert with OK  button and no action
     You must provide at least a message
     Use showOkCancelAlert() if needed to provide choice between action
     */
    func showAlert(title : String = "",
                   message: String){
        let alrt = UIAlertController(title: title,
                                     message: message,
                                     preferredStyle: .alert)
        alrt.addAction(UIAlertAction(title: "OK",
                                     style: .default,
                                     handler: { alrt in }
            )
        )
        
        self.present(alrt, animated: true)
    }
    
}
