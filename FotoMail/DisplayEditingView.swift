//
//  DisplayEditingView.swift
//  FotoMail
//
//  Created by Alistef on 02/12/2016.
//  Copyright © 2016 garfromDev. All rights reserved.
//

import UIKit

/*
 Cette classe implémente une UIView qui affiche une image et dessine par dessus une ligne
 Conçu pour fonctionner en tandem avec une EditingImageView, via un délégué 
 EditingImageController
*/
@objc  class DisplayEditingView: UIView {
    // L'image à afficher
    var backupImage : UIImage!
    // les requêtes de dessin de la ligne
    var drawRequest : [ (from:CGPoint, to:CGPoint)] = []
    // l'échelle de la scrollView où est affichée l'image d'origine
    var scale : CGFloat = 1.0
    // l'offset de l'image à afficher par rapport à la frame
    var offset = CGPoint(x:0,y:0)
    // la couleur du fond
    var bckgrndColor = UIColor.groupTableViewBackground
    
    var drawLayer : CGLayer!
    /*
 le délégué met la ligne dans une propriété de la vue et fait setNeedDisplayInRect
 la vue dessine l'image back-up , la ligne par dessus son image, puis sauve le tout dans une back-up image
 */
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
        
         //on affiche la ou les lignes
        print("handling \(drawRequest.count) draw requests , thick \(30.0*scale)")
        
        while drawRequest.count > 0 {
            let dr = drawRequest[0]
            print("line from \(dr.from) to \(dr.to)")
            self.drawLine(from: dr.from, to: dr.to, thickness: CGFloat(DEFAULT_THICKNESS) * scale)
            drawRequest.remove(at: 0)
        }
        
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
        
        //il faut remetre offset à zéro puisqu'on va sauver l'image entière de la vue, y compris les zones grise au bord
        offset = CGPoint.zero

        //on sauve l'image
        self.backupImage = self.getUIImage()
        //print("draw rect saving \(backupImage)")
    }
    

}
