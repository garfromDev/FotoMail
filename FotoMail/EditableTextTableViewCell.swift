//
//  ETTV - TableViewCell
//
//  Created by Alistef on 02/11/2017.
//  Copyright © 2017 garfromDev. All rights reserved.
//

import UIKit


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
    
    // MARK:- Interface
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
    
    
    /// stope le mode édition du txtField
    func stopEditing(){
        txtField?.resignFirstResponder()
    }
    
    
    // MARK:- Private
    fileprivate var txtField : T!
    
    
    // MARK:- LifeCycle
    override func awakeFromNib() {
        super.awakeFromNib()

        let w = self.bounds.width
        let h = self.bounds.height
        txtField = T(frame: CGRect(x: 8, y: 8, width: w - 16 , height: h - 16))
        txtField.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
        txtField.identifier = reuseIdentifier ?? ""
        contentView.addSubview(txtField)
        print("EditableTextTableViewCell awakeFromNib index \(modelIndex)")
    }


    //on fournit un moyen de voir ce que contient la cellule et son textField
    override public var description: String{
        return "EditableTextTableViewCell index:\(modelIndex) txtFieldIndex:\(txtField.modelIndex) txtFieldText:\(txtField.text ?? "no text") delegateIndex \( (txtField.delegate) as! ETTVTextFieldDelegate).modelIndex"
    }
}




