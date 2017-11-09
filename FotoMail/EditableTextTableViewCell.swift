//
//  ETTV - TableViewCell
//
//  Created by Alistef on 02/11/2017.
//  Copyright © 2017 garfromDev. All rights reserved.
//

import UIKit

/*
 le textField doit être un textField normal, mais ayant pour délgéué un TitleTextFieldDelegate
 et répondant au protocol ModelIndexed
 La cellule 
 */


/// cellule d'une ETTV
typealias EditableTextTableCell = UITableViewCell & ModelIndexed & ModelTextSetable

protocol ModelTextSetable {
    var modelText : String? {get set}
}


/**
Cellule contenant un champ texte éditable, pour utilisation dans une table View
Personalisée avec un délégué qui validera le texte saisie
 est ModelTextSetable pour être initalisée avec le texte issu du modèle
 est ModelIndexed pour relier le texte édité à l'index du modèle
*/

class EditableTextTableViewCell<T:EditableTableViewTextField>: UITableViewCell , ModelIndexed , ModelTextSetable{

    var modelText : String? {
        didSet {
            txtField?.text = modelText
        }
    }
    
    var modelIndex : Int = 0 {
        didSet{
            txtField?.tag = modelIndex
        }
    }
    
    private var txtField : T!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        txtField = T(frame: CGRect(x: 8, y: 0, width: 250, height: 25))
        txtField.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
        txtField.identifier = reuseIdentifier ?? ""
        txtField.modelIndex = modelIndex
        contentView.addSubview(txtField)
        // Initialization code
    }

}




