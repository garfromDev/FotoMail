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
@objc protocol ModelIndexed {
    var modelIndex : Int {get set}
}

/// cet objet est paramétrable via l'identifier de cellule à utiliser 
@objc protocol CellIdentifiable {
    var identifier: String { get set}
}

/// TextField pour les cellules de ETTV
typealias EditableTableViewTextField = UITextField & ModelIndexed & CellIdentifiable

/**
 Un champ de text qui est :
 - personalisable par un delegate qui permet de valider le texte saisie
 - Cellidentifiable, pour pourvoir filtrer les messages qui seront émis par le délégué
 - ModelIndexed, pour ratacher le texte édité à un élément du modèle
 */
class TableViewTextField<D:IsInitializable & UITextFieldDelegate & CellIdentifiable & ModelIndexed>: UITextField, CellIdentifiable, ModelIndexed {

    var identifier: String = ""
    
    var modelIndex: Int = 0
    
    
    override init(frame:CGRect){
        super.init(frame: frame)
        let dlg = D() //le delegué sera chargé de valider le texte saisie
        //on lui transmet les informations nécessaires pour identifier les messages émis
        // ceci suppose que l'ilitialisation soit effectué via l'initialisateur de convenience
        dlg.identifier = identifier
        dlg.modelIndex = modelIndex
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
