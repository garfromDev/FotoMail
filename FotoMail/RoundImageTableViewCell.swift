//
//  RoundImageTableViewCell.swift
//  FotoMail
//
//  Created by Alistef on 04/01/2017.
//  Copyright © 2017 garfromDev. All rights reserved.
//

import UIKit

/// une UITableViewCell dont l'mage a les coins arrondi (pour utilisation storyboard)
/// et dont les bords sont arrondis avec un tour noir (pour utilisation sur fond noir)
class RoundImageTableViewCell: UITableViewCell {

    @objc override func awakeFromNib() {
        super.awakeFromNib()
        self.imageView?.layer.cornerRadius = CGFloat(CORNER_RADIUS)
        self.layer.cornerRadius = CGFloat(CORNER_RADIUS)
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.borderWidth = 3.0
    }


}
