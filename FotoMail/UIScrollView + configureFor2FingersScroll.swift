//
//  UIScrollView + configureFor2FingersScroll.swift
//  FotoMail
//
//  Created by Alistef on 27/03/2017.
//  Copyright © 2017 garfromDev. All rights reserved.
//

import UIKit

/// this extension provide a convenience function to configure a scrollview to use 2 finger to scroll the content
extension  UIScrollView //configureFor2FingersScroll)
{
    /** configure a scrollview to use 2 finger to scroll the content
     */
    func configureFor2FingersScroll(){
        guard let recognizers = self.gestureRecognizers else { return }
        for gestureRecognizer in recognizers {
            if gestureRecognizer.isKind(of: UIPanGestureRecognizer.self){
                (gestureRecognizer as! UIPanGestureRecognizer).minimumNumberOfTouches = 2
                // évite que les évènements soient envoyé  à la vue avant quer la reconnaissance des 2 doigts ait lieu
                //                (gestureRecognizer as! UIPanGestureRecognizer).delaysTouchesEnded = true n'empeche pas les <cancelled>
                // delaysTouchesBegan Ne marche pas, on ne reçoit plus les éléments
            }
        }
    }

}
