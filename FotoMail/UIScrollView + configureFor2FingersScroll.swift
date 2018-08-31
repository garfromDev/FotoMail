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


/// this extension provide a calculation of the CGRect that correspond to the portion of the image on the screen
extension UIScrollView{
    func onScreenRect()->CGRect{
        /* besoin de comprendre :
         la taille à l'écran en pixel est .frame
         la taille de l'image complète au niveau de zoom est .contentSize
         le .contentOffset est le décalage de la frame dans l'image au niveau de zoom
         du coup, la coin du rectangle est .contentOffset / zoomSCale?
         sa taille est .frame / .zoomSCale?
         ATTENTION : marche en paysage, ou il faut inverser les coordonnées?
         => faire des essais dans un truc séparé
         */
        //let  w  = self.frame.width / self.zoomScale
        return CGRect(origin: self.contentOffset, size: self.frame.size).scaledBy(1/Float(self.zoomScale))
    }
    
    
    /**
        insert a new image into the UIImageView handled by the scollView
        CAUTION : works only if scrollview subview is an ImageView
    */
    func insertImage(_ img:UIImage){
        guard let imgView = self.subviews.first as? UIImageView else {return}
        self.minimumZoomScale = 0.0
        self.zoomScale = 1.0
        imgView.frame = CGRect(x: 0.0, y: 0.0, width: img.size.width, height: img.size.height)
        imgView.image = img
        self.minimumZoomScale = 1.0
        self.layoutIfNeeded()
    }
    
    
    /// if the subview of the scrollview is an image view, crop it to the visible on screen
    @discardableResult func cropImageToAeraVisibleonScreen()->UIImage?{
        guard let imgView = self.subviews.first as? UIImageView else {return nil}
        guard let img = imgView.image else {return nil}
        // crop the image
        guard let croppedImg = img.croppedImage(in:self.onScreenRect()) else {return nil}
        // re-insert it into the scrollview, same zoom factor
        imgView.image? = croppedImg
        self.contentOffset = CGPoint.zero
        return croppedImg
    }
    
}
