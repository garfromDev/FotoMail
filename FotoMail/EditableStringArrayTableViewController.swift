//
//  ETTV - EditableStringArrayTableViewController
//  FotoMail
//
//  Created by Alistef on 03/11/2017.
//  Copyright © 2017 garfromDev. All rights reserved.
//

import UIKit

/**
 Protocol décrivant un controlleur de TableView qui gère un tableau de chaine
 paramétrable via le bloc saveModel pour gérer la persistence
 */
protocol StringArrayTableViewController {
    var model: [String] { get set}
    var saveModel: ([String]) -> Void { get set}
}

/**
 Ce TableViewControler gère un tableau de String, que l'on peut
 éditer via des champs de texte
 pour utilisation, il faut
 créer un TableViewController de ce type dans Storyboard
 fixer le type de cellule à un type compatible avec EditableTextTableCell
 fixer le reuseIdentifier  
 personaliser le cell identifier si on n'utilise pas le défaut
 fournir un bloc pour la sauvegarde du modèle si on veut une persistence
 fournir la valeur initiale du modèle si pas vide au départ
 */
class EditableStringArrayTableViewController: UITableViewController, StringArrayTableViewController, CellIdentifiable
{
    // MARK:- Interface
    var model: [String] = [] {
        didSet {
            tableView?.reloadData()
            saveModel(model)
        }
    }
    
    /// table view cell prototype identifier
    var identifier = "textFieldCell"
    
    /// block to be invoqued for persistent saving of the model
    var saveModel: ([String]) -> Void = { (m : [String]) in }
    
    // MARK:- LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //ajoute un bouton plus pour l'ajout d'une ligne vierge
        let addButton = UIBarButtonItem(barButtonSystemItem: .add,
                                        target: self,
                                        action: #selector(addItem))
        self.navigationItem.rightBarButtonItem = addButton
        updateAddButtonStatus()
        NotificationCenter.default.addObserver(self, selector: #selector(textFieldDidChange(notification:)), name: UITextField.textDidEndEditingNotification, object: nil)
        
        // hide separator for empty cells
        tableView.tableFooterView = UIView(frame: CGRect.zero)
    }

    
    // on résilie les abonnements
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // only 1 section in ETTV
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("numberOfRowsInSection \(model.count)")
        print("model : \(model)")
        return model.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        var cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! EditableTextTableCell
        
        // Configure the cell...
        cell.modelIndex = indexPath.row
        cell.modelText = model[indexPath.row]
        
        return cell
    }
    

    // MARK: - TableViewDelegate
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            model.remove(at: indexPath.row)
            tableView.reloadData()
            updateAddButtonStatus()
        }
    }
    
    private var previousSelected : Int?
    
    
    @objc func addItem(){
        print("addItem  nb before = \(model.count)")
        let s = ""
        model.append(s)
        tableView?.reloadData()
        updateAddButtonStatus()
    }
    
    
    // MARK: - TextField Management
    
    /// est appellé en cas de modification d'un champ de texte, met à jour le modèle
    @objc func textFieldDidChange(notification:Notification)
    {
        print("textFieldDidChange ")
        // on vérifie que la notification s'acompagne d'un objet
        guard let o = notification.object  else { return }
        // on récupère le champ de texte si il est du bon type
        guard let txtField = o as? EditableTableViewTextField else { return }
        // on vérifie que l'identifier correspond
        guard txtField.identifier == identifier else { return }
        // on met à jour le modèle avec la valeur du champ de texte
        model[txtField.modelIndex] = txtField.text ?? ""
        print("textField n° \(txtField.modelIndex) new value \(txtField.text!)")
        
        updateAddButtonStatus()
    }
    
    
    // MARK: - UI state management
    
    /// le bouton "Add" est actif uniquement lorsque la dernière ligne n'est pas vide
    private func updateAddButtonStatus()
    {
        if let lastItem = model.last {
            self.navigationItem.rightBarButtonItem?.isEnabled = (lastItem != "")
        }
    }
    

}


