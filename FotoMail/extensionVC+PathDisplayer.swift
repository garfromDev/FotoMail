//
//  extensionVC+PathDisplayer.swift
//  FotoMail
//
//  Created by Alistef on 07/08/2017.
//  Copyright © 2017 garfromDev. All rights reserved.
//

import Foundation

extension ViewController : PathDisplayer {
    func updateDisplay() {
        clrView?.setNeedsDisplay()
    }
}
