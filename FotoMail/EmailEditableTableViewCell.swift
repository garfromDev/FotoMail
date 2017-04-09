//
//  EmailEditableTableViewCell.swift
//  FotoMail
//
//  Created by Alistef on 21/12/2016.
//  Copyright © 2016 garfromDev. All rights reserved.
//

import UIKit

/// Une cellule TableView qui contient un champ texte editable et un bouton contact pour ajouter un e-mail
class EmailEditableTableViewCell: UITableViewCell {

    @IBOutlet weak var textField: UITextField!
    
    @IBOutlet weak var contactButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
