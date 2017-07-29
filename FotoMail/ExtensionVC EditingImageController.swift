//
//  ExtensionVC EditingImageController.swift
//  FotoMail
//
//  Created by Alistef on 16/08/2016.
//  Copyright © 2016 garfromDev. All rights reserved.
//

import Foundation

// implentation of the protocol EditingImageViewController to work with the EditingImageView
extension ViewController : EditingImageViewController {
    
    public func initView(with image: UIImage!, scale : CGFloat, offset : CGPoint, contentOffset: CGPoint, overPaths : [OverPath]) {
        print("init view with image \(image) at scale \(image.scale) offset \(offset) contentOffset \(contentOffset) overPath \(overPaths.count)")
        // en arrière plan, la photo
        self.backgroundPseudoImageView.image = image
        self.backgroundPseudoImageView.offset = offset
        
        // devant, la couche transparente qui servira au dessin
        displayEditingView.overPaths = overPaths
        self.displayEditingView.scale = scale
        self.displayEditingView.offset = contentOffset
        
        //    ne pas faire de setNeddDisplay() ici sinon on obtient un carrée noir
    }

    
    // La vue de la scroll view signale une demande d'édition (l'utilisateur a posé le doigt)
    public func editingRequested(_ fromView:EditingImageView ) {
        print("editingRequested()")
        self.previewStackView.isHidden = true
        backgroundPseudoImageView.isHidden = false
        backgroundPseudoImageView.setNeedsDisplay() //vérifier si vraiment nécessaire? -> oui, ça l'est
        displayEditingView.isHidden = false
        self.displayEditingView.setNeedsDisplay()
        
        print("scollview replaced by drawingImage View : \(displayEditingView.bounds)")
    }
    
    
    // la vue de la scroll view signale que l'édition est terminée (l'utilisateur a levé le doigt)
    public func editingFinished(_ fromView:EditingImageView) {
        print("editingFinished() by view \(fromView.tag)")
        //on réaffiche la scrollView et masque les vues de dessin
        self.previewStackView.isHidden = false
        self.backgroundPseudoImageView.isHidden = true
        self.displayEditingView.isHidden = true

    }
    

    
    public func getDisplaySize() -> CGSize {
        return self.displayEditingView.bounds.size
    }

    public func getScrollView() -> UIScrollView! {
        return self.scrollView
    }
    

    public func updateDisplay( with touch : UITouch,  paths: [OverPath] ) {
        //print("updateDisplay(with image:")
        // l'utilisation d'une UIimageView avec self.drawingImageView.image = image provoque des carrés noir dans les marges
        //        image.draw(at: CGPoint(x: 0, y: 0)) //-> marche pas, image non affiché,  pas le bon contexte, il faut être dans drawRect:
        let fromPoint = touch.previousLocation(in: self.displayEditingView)
        let endPoint = touch.location(in: self.displayEditingView)
        let thick = max(CGFloat(DEFAULT_THICKNESS) * self.displayEditingView.scale, 10.0)
        let rect = CGRect( x:min(fromPoint.x, endPoint.x),
                           y:min(fromPoint.y, endPoint.y),
                           width:fabs(fromPoint.x - endPoint.x),
                           height:fabs(fromPoint.y - endPoint.y)).insetBy(dx: -thick, dy: -thick)
        // il faut agrandir le rectangle, sinon le dessin de la ligne sera clippé
        self.displayEditingView.overPaths = paths
//        self.displayEditingView.setNeedsDisplay(rect) //est-ce que on contraint trop la zone?
        self.displayEditingView.setNeedsDisplay()
    }
}
