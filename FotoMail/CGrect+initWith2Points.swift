//
//  CGrect+initWith2Points.swift
//  FotoMail
//
//  Created by Alistef on 06/05/2017.
//  Copyright © 2017 garfromDev. All rights reserved.
//

import Foundation
extension CGRect {
    init( origin:CGPoint, to:CGPoint){
        let w = abs(to.x - origin.x)
        let h = abs(to.y - origin.y)
        let x = min(origin.x, to.x)
        let y = min(origin.y, to.y)
        self.init(origin:CGPoint(x: x, y: y), size: CGSize(width:w, height:h))
    }
}
