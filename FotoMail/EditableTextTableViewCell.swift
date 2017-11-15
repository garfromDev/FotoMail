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
typealias EditableTextTableCell = UITableViewCell & ModelIndexed & ModelTextSetable & TextFieldEditable

protocol ModelTextSetable {
    var modelText : String? {get set}
}

protocol TextFieldEditable {
    func stopEditing()
}

/**
Cellule contenant un champ texte éditable, pour utilisation dans une table View
Personalisée avec un délégué qui validera le texte saisie
 est ModelTextSetable pour être initalisée avec le texte issu du modèle
 est ModelIndexed pour relier le texte édité à l'index du modèle
*/

class EditableTextTableViewCell<T:EditableTableViewTextField>: UITableViewCell , ModelIndexed , ModelTextSetable, TextFieldEditable{

    var modelText : String? {
        didSet {
            txtField?.text = modelText
            print("EditableTextTableViewCell text set to \(modelText ?? "no text")  was \(oldValue ?? "no text") index : \(modelIndex)")
        }
    }
    
    var modelIndex : Int = 0 {
        didSet{
            txtField.modelIndex = modelIndex
            print("EditableTextTableViewCell index set to \(modelIndex)  was \(oldValue) texfield content \(txtField?.text ?? "") ")
        }
    }
    
    fileprivate var txtField : T!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        txtField = T(frame: CGRect(x: 8, y: 8, width: 300, height: 25))
        txtField.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
        txtField.identifier = reuseIdentifier ?? ""
        //txtField.modelIndex = modelIndex //FIXME: n'ets pas setté au moemetn d'awake from Nib
        contentView.addSubview(txtField)
        print("EditableTextTableViewCell awakeFromNib index \(modelIndex)")
    }

    // stope le mode édition du txtField
    func stopEditing(){
        txtField?.resignFirstResponder()
    }
    
    //on fournit un moyen de voir ce que contient
    override public var description: String{
        return "EditableTextTableViewCell index:\(modelIndex) txtFieldIndex:\(txtField.modelIndex) txtFieldText:\(txtField.text ?? "no text") delegateIndex \( (txtField.delegate) as! ETTVTextFieldDelegate).modelIndex"
    }
}




