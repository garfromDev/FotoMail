//
//  ChooseProject.swift
//  FotoMail
//
//  Created by Alistef on 10/11/2017.
//  Copyright © 2017 garfromDev. All rights reserved.
//
// Les objets personalisés nécessaire pour le controleur ETTV
// permettant d'éditer la liste de projets
// le controler lui-même est instancié dans le prepareSegue du
// SettingsViewControler

import Foundation

/** un textFieldDelegate basé sur TitleTextField, qui lui rajoute les propriétés nécessaires
 pour respecter les protocoles. Doit être final pour éviter les problèmes avec init()
 */
final class ProjectTextFieldDelegate: TitleTextFieldDelegate, IsInitializable, ModelIndexed, CellIdentifiable {
    var modelIndex: Int = 0
    var identifier: String = ""
}

/// un textField personalisé avec le delegate ProjectTextFieldDelegate
class ProjectTextField: TableViewTextField<ProjectTextFieldDelegate> {}

/// une cellule personalisée avec ce textField
class ProjectCell: EditableTextTableViewCell<ProjectTextField> {}

