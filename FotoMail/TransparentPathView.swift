//
//  TransparentPathView.swift
//  FotoMail
//
//  Created by Alistef on 07/08/2017.
//  Copyright © 2017 garfromDev. All rights reserved.
//

import UIKit


@objc protocol PathProvider :class {
    func offset() -> CGPoint
    func scale() -> CGFloat
    func getPaths()-> [OverPath]
}

/*! une vue transparente, qui affiche les paths
 */

@objc class TransparentPathView: UIView {

    weak var delegate : PathProvider!
    
    
    override func draw(_ rect: CGRect) {
        
        guard let dlg = delegate  else { return }
        
        let paths = dlg.getPaths()
        guard  !paths.isEmpty else { return }

        let context = UIGraphicsGetCurrentContext()
        let scale = dlg.scale()
        let offset = dlg.offset()

        //  le décalage de la scrollView est exprimé en point au niveau de zoom donnée, donc en point écran,
        // donc on prend l'opposé avant d'appliquer la mise à l'échelle
        context?.translateBy(x: -offset.x, y: -offset.y)
        //Il faut appliquer le même zoom que la scrollview
        context?.scaleBy(x: scale, y: scale)
        
        for p in paths {
            if p.rubber {
                context?.setBlendMode(.destinationOut)
                UIColor.white.set()
            }else{
                context?.setBlendMode(.normal)
                p.drawColor.set()
                print("drawing path \(p.path.bounds)")
            }
            p.path.stroke()
        }
    }

}
