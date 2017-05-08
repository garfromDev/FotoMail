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
    /// L'image à afficher
    var backupImage : UIImage!
    /// l'image avant édition pour la fonction gomme
    var initialImage : UIImage!
    /// les requêtes de dessin de la ligne
    var drawRequest : [ (from:CGPoint, to:CGPoint, rubber:Bool)] = []
    /// l'échelle de la scrollView où est affichée l'image d'origine
    var scale : CGFloat = 1.0
    /// l'offset de l'image à afficher par rapport à la frame
    var offset = CGPoint(x:0,y:0)
    /// la couleur du fond, qui s'affiche autour de l'image si nécessaire
    var bckgrndColor = UIColor.groupTableViewBackground
    
    //var drawLayer : CGLayer!
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
        //print("handling \(drawRequest.count) draw requests , thick \(30.0*scale)")
        
        while drawRequest.count > 0 {
            let dr = drawRequest[0]
            print("line from \(dr.from) to \(dr.to) rubber : \(dr.rubber)")
            if(!dr.rubber){ // mode dessin
                self.drawLine(from: dr.from, to: dr.to, thickness: CGFloat(DEFAULT_THICKNESS) * scale)
            }else{ // mode gomme
                let img = self.initialImage
                let drect = CGRect(origin: dr.from, to: dr.to)
                let  oldImg = EditingImageView.image(from: img, in: drect)
                print("erasing... \(oldImg)")
                
                // dans le cas ou l'image est plus petite que l'écran, il faut la centrer
                oldImg?.draw(at: drect.origin)
                let context = UIGraphicsGetCurrentContext()!
                context.setStrokeColor(UIColor.blue.cgColor)
                context.stroke(drect.insetBy(dx: 0, dy: 0))
                //                self.erase(from: dr.from, to: dr.to,
                //                           thickness: CGFloat(DEFAULT_RUBBER_THICKNESS)*scale,
                //                           inRect: rect, atOrg: org)
            }
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
    
    
     
    /**
     Efface la portion d'image entre les 2 points en la recouvrant par initialImage
     - Parameter from: le point de départ
     - Parameter to: le point d'arrivé
     - Parameter thickness : la largeur de la zone à effacer
     - Parameter inRect : le rectangle dans lequel le re-dessin à lieu
     - Parameter atOrg : l'origine à appliquer pour dessinner l'image, compte tenu de l'offset
     - Discussion : cette fonction est destinée à être appellée depuis drawRect()
     elle dessinne dans le contexte courant sans le modifier
     */
    private func erase(from:CGPoint,  to:CGPoint, thickness:CGFloat, inRect : CGRect, atOrg : CGPoint )
    {
        //note : rubberImg.draw ne fonctionne pas dans le drawRect
        
        guard let img = self.initialImage else {return}
        let oldImg = EditingImageView.image(from: img, in: inRect)
        // dans le cas ou l'image est plus petite que l'écran, il faut la centrer
        oldImg?.draw(at: atOrg)
        //on sauve le context avant clipping
//        let context = UIGraphicsGetCurrentContext()
//        context?.saveGState()
        // on prépare le path pour le clipping
//        context?.beginPath()
//        let l = UIBezierPath()
//        l.lineWidth =  thickness //CGFloat(DEFAULT_RUBBER_THICKNESS)
//        l.lineJoinStyle = .round
//        l.lineCapStyle = .round
//        l.move(to: from)
//        l.addLine(to: to)
//        l.addClip()
        //context?.clip(to: CGRect(origin: from, size: CGSize(width: to.x - from.x, height: to.y - from.y))
//        let rect = CGRect(origin: CGPoint.zero, size: initialImage.size)
//        let rectRubber = CGRect(origin: from, to: to).insetBy(dx: -10, dy: -10)
//        let context = UIGraphicsGetCurrentContext()
////        if((context == nil)){print("problème de contexte")}
////        context?.saveGState()
//        context?.clip(to: rectRubber)
//        let rubberImg = self.initialImage!
////        context?.translateBy(x: 0, y: rubberImg.size.height)
////        context?.scaleBy(x: 1.0 , y: -1.0 )
////        let imgtest = rubberImg.cgImage!
//        context?.draw(rubberImg.cgImage!, in: rect)
//
//        context?.setFillColor(UIColor.blue.cgColor)
////        context?.fill(inRect)
//        print("drawing \(rubberImg)")
////        rubberImg.draw(at: CGPoint.zero)
//        context?.restoreGState()
////        rubberImg?.draw(at: from)
        // on désactive le clipping
        //context?.restoreGState()
    }

}
