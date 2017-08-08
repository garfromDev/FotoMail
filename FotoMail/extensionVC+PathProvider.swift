//
//  extensionVC+PathProvider.swift
//  FotoMail
//
//  Created by Alistef on 07/08/2017.
//  Copyright © 2017 garfromDev. All rights reserved.
//

import Foundation

/// le PathProvider fourni les informations nécessaires  à la transparentView
extension ViewController : PathProvider
{
    func offset()->CGPoint {
        return scrollView?.contentOffset ?? CGPoint.zero
    }
    
    
    func scale() -> CGFloat {
        return scrollView?.zoomScale ?? 1.0
    }
    
    func getPaths()->[OverPath] {
        return self.pathManager.paths
    }
    
}
