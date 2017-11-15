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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        //self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        //ajoute un bouton plus pour l'ajout d'une ligne vierge
        let addButton = UIBarButtonItem(barButtonSystemItem: .add,
                                        target: self,
                                        action: #selector(addItem))
        self.navigationItem.rightBarButtonItem = addButton
        updateAddButtonStatus()
        NotificationCenter.default.addObserver(self, selector: #selector(textFieldDidChange(notification:)), name: .UITextFieldTextDidEndEditing, object: nil)
        
        // hide separator for empty cells
        tableView.tableFooterView = UIView(frame: CGRect.zero)
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
    // Override to support conditional editing of the table view.
    /*
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source            
            //tableView.deleteRows(at: [indexPath], with: .fade)
            model.remove(at: indexPath.row)
            tableView.reloadData()
            updateAddButtonStatus()
        }
    }
    
    private var previousSelected : Int?
    
    
//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        return
//        //super.tableView(tableView, didSelectRowAt: indexPath)
//        print("didSelectRowAt \(indexPath.row)")
//        if let prev = previousSelected {
//            let c = tableView.cellForRow(at: IndexPath(row:prev, section:0)) as! EditableTextTableCell
//            c.stopEditing()
//        }
//        previousSelected = indexPath.row
//    }
//
    
    func addItem(){
        print("addItem  nb before = \(model.count)")
        let s = ""
        model.append(s)
       // tableView?.insertRows(at: [IndexPath(row:model.count-1, section:0)], with: .fade) //avant l'ajout, le row était count - 1
        tableView?.reloadData()
        updateAddButtonStatus()
    }
    
    
    // MARK: - TextField Management
    
    /// est appellé en cas de modification d'un champ de texte, met à jour le modèle
    func textFieldDidChange(notification:Notification)
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
    
    /// le bouton "Add" est actif uniquement lorsque la dernière ligne n'est pas vide
    private func updateAddButtonStatus()
    {
        if let lastItem = model.last {
            self.navigationItem.rightBarButtonItem?.isEnabled = (lastItem != "")
        }
    }
    
    // on résilie les abonnements
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    
    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}


