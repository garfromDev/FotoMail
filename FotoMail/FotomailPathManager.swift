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

/// le PathManager décide du mode gomme, de la couleur et de la largeur de trait et stocke les paths
/// travaille avec EditingSupportImageView
@objc class FotoMailPathManager: NSObject, PathManager {
    var rubberMode = false
    var drawColor = UIColor.red
    weak var controller : PathDisplayer!
    var paths : [OverPath] = []
    
    /// ajoute un path au tableau
    func addPath(path: UIBezierPath) {
        let op = OverPath(path: path, draw: self.drawColor, rubber: self.rubberMode)
        self.paths.append(op)
        print("addPath path \(path.bounds)  total : \(paths.count)")
    }
    

    func updateWithPath(path: UIBezierPath) {
        //on crée un overPath avec les infos de gomme et de couleur
        let op = OverPath(path: path, draw: self.drawColor, rubber: self.rubberMode)
        //on le stocke en ramplaçant l'existant
        if self.paths.isEmpty{
            self.paths.append(op)
        }else{
            self.paths[self.paths.count - 1] = op
        }
//        print("update with path : \(paths.last!.path.bounds)  total \(paths.count) path")
        //on prévient le viewControlleur de metre à jour la vue
        controller?.updateDisplay()
    }

    
    func cancelPath() {
        guard !self.paths.isEmpty else { return }
        self.paths.removeLast()
    }
    
    
    func lineWidth()->CGFloat {
        return CGFloat(rubberMode ? DEFAULT_RUBBER_THICKNESS : DEFAULT_THICKNESS)
    }
    
    /// réinitialize les path stockés, ne change pas le mode et la couleur
    @objc func clear(){
        self.paths = []
    }
}
