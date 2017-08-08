//
//  PathManager.swift
//  FotoMail
//
//  Created by Alistef on 07/08/2017.
//  Copyright © 2017 garfromDev. All rights reserved.
//

import Foundation
/*
/// le pathDisplayer met à jour la transparentView, il doit avoir une référence dessus
protocol PathDisplayer {
    func updateDisplay()
}

/// le PathManager décide du mode gomme, de la couleur et de la largur de trait et stocke les paths
@objc class FotoMailPathManager:  NSObject, PathManager {
    
    var rubberMode = false
    var drawColor = UIColor.red
    var controller : PathDisplayer!
    var paths : [OverPath] = []
    
    
    func UpdateWithPath(path: UIBezierPath) {
        //on crée un overPath avec les infos de gomme et de couleur
        let op = ( rubberMode, path, self.drawColor)
        //on le stocke
        self.paths.append(op)
        //on prévient le viewCOntrolleur de metre à jour la vue
        controller?.updateDisplay()
    }
    
    
    func lineWidth()->CGFloat {
        return CGFloat(rubberMode ? DEFAULT_RUBBER_THICKNESS : DEFAULT_THICKNESS)
    }
    
}
*/
