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
    
    public func initView(with image: UIImage!, scale : CGFloat, offset : CGPoint) {
        print("init view with image \(image) at scale \(image.scale)")
        self.diplayEditingView.backupImage = image
        self.diplayEditingView.scale = scale
        self.diplayEditingView.offset = offset
        //    ne pas faire de setNeddDisplay() ici sinon on obtient un carrée noir
    }

    
    // La vue de la scroll view signale une demande d'édition (l'utilisateur a posé le doigt)
    public func editingRequested(_ fromView:EditingImageView , with drawLayer:CGLayer) {
        print("editingRequested()")
        self.previewStackView.isHidden = true
        self.diplayEditingView.isHidden = false
        self.diplayEditingView.setNeedsDisplay() //pour forcer l'affichage de l'image qui a été chargée lors du initView()
        self.diplayEditingView.drawLayer = drawLayer
        print("scollview replaced by drawingImage View : \(diplayEditingView.bounds)")
    }
    
    
    // la vue de la scroll view signale que l'édition est terminée (l'utilisateur a levé le doigt)
    public func editingFinished(_ fromView:EditingImageView) {
        print("editingFinished() by view \(fromView.tag)")
        self.previewStackView.isHidden = false
        self.diplayEditingView.isHidden = true
    }
    

    
    public func getDisplaySize() -> CGSize {
        return self.diplayEditingView.bounds.size
    }

    public func getScrollView() -> UIScrollView! {
        return self.scrollView
    }
    
    public func updateDisplay( with touch : UITouch) {
        print("updateDisplay(with image:")
        // l'utilisation d'une UIimageView avec self.drawingImageView.image = image provoque des carrés noir dans les marges
        //        image.draw(at: CGPoint(x: 0, y: 0)) //-> marche pas, image non affiché,  pas le bon contexte, il faut être dans drawRect:
        let fromPoint = touch.previousLocation(in: self.diplayEditingView)
        let endPoint = touch.location(in: self.diplayEditingView)
        self.diplayEditingView.drawRequest.append((fromPoint,endPoint))
        let thick = max(CGFloat(DEFAULT_THICKNESS) * self.diplayEditingView.scale, 10.0)
        let rect = CGRect( x:min(fromPoint.x, endPoint.x),
                           y:min(fromPoint.y, endPoint.y),
                           width:fabs(fromPoint.x - endPoint.x),
                           height:fabs(fromPoint.y - endPoint.y)).insetBy(dx: -thick, dy: -thick)
        // il faut agrandir le rectangle, sinon le dessin de la ligne sera clippé

        self.diplayEditingView.setNeedsDisplay(rect)
    }
}
