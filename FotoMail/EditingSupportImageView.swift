//
//  EditingSupportImageView.swift
//  testScrollViewPlusTransparent
//
//  Created by Alistef on 30/07/2017.
//  Copyright © 2017 garfromDev. All rights reserved.
//

//================================================
// original dans testScrollViewPlusTransparent
//================================================

import UIKit

/// le délégué gère les mode dessin/gomme, les largeurs de ligne et stocke les paths
@objc protocol PathManager :class {
    // doit être déclarer class: si on veut pouvoir déclarer weak delegate
    func addPath(path:UIBezierPath)
    func updateWithPath(path:UIBezierPath)
    func cancelPath()
    func lineWidth()->CGFloat
}

/// cette UIImageView fournie un path au délégué  à chaque mouvement du doigt sur l'image
class EditingSupportImageView: UIImageView {

    weak var delegate : PathManager!
    
    private var paths = UIBezierPath()
    private var isDrawing = false
    
    // Initialize le path avec la largeur de ligne fournie par le délégué
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        print("\(String(describing: event?.allTouches?.count)) touch began")
        guard (event!.allTouches!.count) < 2 else { return } //évite de prendre en compte les geste de scroll et zoom
        paths = UIBezierPath()
        guard let lw = delegate?.lineWidth() else {return}
        paths.lineWidth = lw
        paths.lineJoinStyle = .round
        paths.lineCapStyle = .round
        
        isDrawing = true        
        super.touchesBegan(touches, with: event)
    }

    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        print("touch moved")
        guard isDrawing else { return }
        
        let touch = touches.first!
        let pos = touch.location(in: self)
        let start = touch.previousLocation(in: self)
        
        if paths.isEmpty {
            paths.move(to: start)
            paths.addLine(to: pos)
            delegate?.addPath(path: paths)
        }else{
            paths.addLine(to: pos)
            delegate?.updateWithPath(path: self.paths)
        }
        super.touchesMoved(touches, with: event)
    }

    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("\(String(describing: event?.allTouches?.count)) touch Ended")
        isDrawing = false
        super.touchesEnded(touches, with: event)
    }
    
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("\(touches.count) touch cancelled")
        isDrawing = false
        //delegate?.cancelPath() //v1.4 : on ne gère plus le touch cancelled, puisque on est protégé contre les multi-touch
        // ce la évite l'annulation des gestes très courts
        
        super.touchesCancelled(touches, with: event)
    }
    

}
