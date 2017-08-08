//
//  DisplayEditingView.swift
//  FotoMail
//
//  Created by Alistef on 02/12/2016.
//  Copyright © 2016 garfromDev. All rights reserved.
//

import UIKit

/**
 Cette classe implémente une UIView qui affiche une image et dessine par dessus une ligne
 Conçu pour fonctionner en tandem avec une EditingImageView, via un délégué
 EditingImageController
 La DisplayEditingView affiche une image à la taille de l'écran, avec dessin en temps réel
 L'EditingImageView contient une image haute résolution et dessinne dedans en tache de fond
 */
@objc  class DisplayEditingView: UIView {

    /// l'échelle de la scrollView où est affichée l'image d'origine
    var scale : CGFloat = 1.0
    /// l'offset de l'image à afficher par rapport à la frame
    var offset = CGPoint(x:0,y:0)

    // le tableau des paths à dessiner, le dernier d'entre eux doit être complétété
    var overPaths : [OverPath] = []
    
    
    /*
     le délégué met les path dans une propriété de la vue et fait setNeedDisplayInRect
     la vue dessine les path en couleur ou en transparent
     */
    
    override func draw(_ rect: CGRect) {
        
        let context = UIGraphicsGetCurrentContext()
        context?.scaleBy(x: self.scale, y: self.scale)
        context?.translateBy(x: -self.offset.x, y: -self.offset.y)
        
        for p in self.overPaths {
            
            if p.rubber {
                context?.setBlendMode(.destinationOut)
                UIColor.white.set()
            }else{
                context?.setBlendMode(.normal)
                p.drawColor.set()
            }
            p.path.stroke()
        }
    }
    
}
