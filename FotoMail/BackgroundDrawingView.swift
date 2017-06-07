//
//  BackgroundDrawingView.swift
//  FotoMail
//
//  Created by Alistef on 08/05/2017.
//  Copyright © 2017 garfromDev. All rights reserved.
//

import UIKit

@objc  class BackgroundDrawingView: UIView {
    /// L'image à afficher
    var backupImage : UIImage!
      /// l'échelle de la scrollView où est affichée l'image d'origine
    var scale : CGFloat = 1.0
    /// l'offset de l'image à afficher par rapport à la frame
    var offset = CGPoint(x:0,y:0)
    /// la couleur du fond, qui s'affiche autour de l'image si nécessaire
    var bckgrndColor = UIColor.groupTableViewBackground

    
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // on récupère l'ancienne image
        guard let img = self.backupImage else {return}
        
        let frm = self.frame
        //on remet le fond gris si il y a besoin d'un fond (quand l'image est plus petite avec un offset)
        if offset.x > 0 || offset.y > 0 {
            let r = UIBezierPath(rect: frm)
            bckgrndColor.setFill()
            r.fill()
        }
        
        // on réaffiche l'image dans le rectangle
        let oldImg = EditingImageView.image(from: img, in: rect)
        // dans le cas ou l'image est plus petite que l'écran, il faut la centrer
        let org = CGPoint(x: offset.x + rect.origin.x, y: offset.y + rect.origin.y)
        oldImg?.draw(at: org)
       
    }
    

}
