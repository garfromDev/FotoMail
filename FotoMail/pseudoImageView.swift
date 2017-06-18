//
//  pseudoImageView.swift
//  FotoMail
//
//  Created by Alistef on 07/06/2017.
//  Copyright © 2017 garfromDev. All rights reserved.
//

import UIKit

class PseudoImageView: UIView {
    
    var image : UIImage!
    /// l'offset de l'image à afficher par rapport à la frame
    var offset = CGPoint(x:0,y:0)
    /// la couleur du fond, qui s'affiche autour de l'image si nécessaire
    var bckgrndColor = UIColor.groupTableViewBackground
    
    override func draw(_ rect: CGRect) {
        let frm = self.frame
        
        //on remet le fond gris si il y a besoin d'un fond (quand l'image est plus petite avec un offset)
        if offset.x > 0 || offset.y > 0 {
            let r = UIBezierPath(rect: frm)
            bckgrndColor.setFill()
            r.fill()
        }
        
        // on réaffiche l'image dans le rectangle
        let oldImg = EditingImageView.image(from: image, in: rect)
        // dans le cas ou l'image est plus petite que l'écran, il faut la centrer
        let org = CGPoint(x: offset.x + rect.origin.x, y: offset.y + rect.origin.y)
        oldImg?.draw(at: org)
        
        
        // le img.draw provoque une bande noire à droite, on la recouvre par du gris
        if offset.x > 0 {
            let rectD = CGRect(x: frm.width - offset.x, y: 0, width: offset.x, height: frm.height)
            self.drawRect(inRect:rectD, color:bckgrndColor)
        }
        
        // le img.draw provoque une bande noire en dessous, on la recouvre par du gris
        if offset.y > 0 {
            let rectB = CGRect(x: 0, y: frm.height - offset.y, width: frm.width, height: offset.y)
            self.drawRect(inRect:rectB, color:bckgrndColor)
        }
    }
    
}
