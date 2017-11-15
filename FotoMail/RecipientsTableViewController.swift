//
//  RecipientsTableViewController.swift
//  FotoMail
//
//  Created by Alistef on 20/12/2016.
//  Copyright © 2016 garfromDev. All rights reserved.
//

import UIKit
import ContactsUI
import AddressBookUI

/// Handle the screen where user choose email adress for recipients
/// NOTE : iOS9 required
class RecipientsTableViewController: UITableViewController  {

    var emailAdress = [""]
    var editedRow : Int!
    var editedTextField : UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // chargement des adresses
        emailAdress = FotomailUserDefault.defaults().recipients
        // on ajoute une chaine vide à la fin si nécessaire pour pouvoir entrer une nouvelle adresse
        if emailAdress.last != "" {
            emailAdress.append("")
        }
        
        // préparation de la tableView
        tableView.delegate = self
        tableView.dataSource = self
        
    }

    
    @IBAction func chooseContact(_ sender: Any) {
        // comment on trouve l'émetteur -> par le tag
        // le tag a été fixé dans le cell for indexPath du Datasource
        let bouton = sender as! UIButton
        editedRow = bouton.tag
        
        //on prépare le picker pour choisir le contact à ajouter
        // il affichera les adresses e-mail des contacts qui en on une
        if #available(iOS 9.0, *) {
            let picker = CNContactPickerViewController()
            picker.displayedPropertyKeys = [ CNContactEmailAddressesKey]
            let pred = NSPredicate(format: "emailAddresses.@count > 0", argumentArray: nil)
            picker.predicateForEnablingContact = pred
            picker.delegate = self
            
            //on présente le picker, le retour sera traité dans Recipients_CNContactPickerDelegate
            self.present(picker, animated: true, completion: nil)

        }
    }
   
 

// MARK: - Table view editing
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        // on n'a pas le droit de supprimer la ligne vide "Enter e-mail adress"
        return emailAdress[indexPath.row] != ""
    }
   

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            emailAdress.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
        
        tableView.reloadData()
    }
   

}
