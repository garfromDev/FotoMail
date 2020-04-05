//
//  ETTV - TextField
//
//  Created by Alistef on 07/11/2017.
//  Copyright © 2017 garfromDev. All rights reserved.
//

import UIKit

// thanks andrey https://stackoverflow.com/questions/46056094/using-generic-function-in-base-class
protocol IsInitializable {
    init()
}

/// décrit un objet se reliant à l'index du tableau modèle
@objc public protocol ModelIndexed {
    var modelIndex : Int {get set}
}

/// cet objet est paramétrable via l'identifier de cellule à utiliser 
@objc protocol CellIdentifiable {
    var identifier: String { get set}
}

///Delegate pour les textField ETTV
typealias ETTVTextFieldDelegate = UITextFieldDelegate & IsInitializable & CellIdentifiable & ModelIndexed

/// TextField pour les cellules de ETTV
typealias EditableTableViewTextField = UITextField & ModelIndexed & CellIdentifiable

/**
 Un champ de text qui est :
 - personalisable par un delegate qui permet de valider le texte saisie
 - Cellidentifiable, pour pourvoir filtrer les messages qui seront émis par le délégué
 - ModelIndexed, pour ratacher le texte édité à un élément du modèle
 */
class TableViewTextField<D:IsInitializable & UITextFieldDelegate>: UITextField, CellIdentifiable, ModelIndexed {

    var identifier: String = ""
    
    var modelIndex: Int = 0

    
    private var dlg : D! //il faut garder vivant le délégué, car UITextField a une référence weak sur delegate
    
    override init(frame:CGRect){
        super.init(frame: frame)
        dlg = D() //le delegué sera chargé de valider le texte saisie
        self.delegate = dlg
    }
    
    
    convenience init(frame:CGRect, identifier:String, index:Int)
    {
        self.init(frame:frame)
        self.identifier = identifier
        self.modelIndex = index
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
