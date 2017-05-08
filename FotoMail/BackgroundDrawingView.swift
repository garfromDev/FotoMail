//
//  BackgroundDrawingView.swift
//  FotoMail
//
//  Created by Alistef on 08/05/2017.
//  Copyright © 2017 garfromDev. All rights reserved.
//

import UIKit

class BackgroundDrawingView: UIView {
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
        // Drawing code
    }
    

}
