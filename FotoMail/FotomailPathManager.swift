//
//  FotomailPathManager.swift
//  FotoMail
//
//  Created by Alistef on 07/08/2017.
//  Copyright © 2017 garfromDev. All rights reserved.
//

import UIKit

/// le pathDisplayer met à jour la transparentView, il doit avoir une référence dessus
@objc protocol PathDisplayer :class{
    func updateDisplay()
}

/// le PathManager décide du mode gomme, de la couleur et de la largur de trait et stocke les paths
/// travaille avec EditingSupportImageView
@objc class FotoMailPathManager: NSObject, PathManager {
    var rubberMode = false
    var drawColor = UIColor.red
    weak var controller : PathDisplayer!
    var paths : [OverPath] = []
    
    
    func UpdateWithPath(path: UIBezierPath) {
        //on crée un overPath avec les infos de gomme et de couleur
        let op = OverPath(path: path, draw: self.drawColor, rubber: self.rubberMode)
        //on le stocke
        self.paths.append(op)
        //on prévient le viewControlleur de metre à jour la vue
        controller?.updateDisplay()
    }
    
    
    func lineWidth()->CGFloat {
        return CGFloat(rubberMode ? DEFAULT_RUBBER_THICKNESS : DEFAULT_THICKNESS)
    }
    
    /// réinitialize les path stockés, ne change pas le mode et la couleur
    @objc func clear(){
        self.paths = []
    }
}
