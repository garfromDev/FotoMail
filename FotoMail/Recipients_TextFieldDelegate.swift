//
//  Recipients_TextFieldDelegate.swift
//  FotoMail
//
//  Created by Alistef on 21/12/2016.
//  Copyright © 2016 garfromDev. All rights reserved.
//

import UIKit

extension RecipientsTableViewController : UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField)
    {
        guard let txt = textField.text  else { return }
        self.changeContentOfRow(editedRow: textField.tag, by: txt)
        textField.resignFirstResponder()
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
 
    
    func changeContentOfRow( editedRow: Int, by txt:String){
        print("Change content of row \(editedRow) by \(txt)")
        emailAdress[editedRow] = txt
        
        if txt == "" && editedRow < emailAdress.count - 1 { //supression d'une ligne
            emailAdress.remove(at: editedRow)
        }
        
        if editedRow == emailAdress.count - 1 && txt != "" { // ajout d'une ligne
            emailAdress.append("")
        }
        
        tableView.reloadData()
        // on sauve la list en préférence, sans inclure l'adresse vide  à la fin
        if emailAdress.last == "" {
            FotomailUserDefault.defaults().recipients = Array(emailAdress.dropLast())
        }else{
            FotomailUserDefault.defaults().recipients = emailAdress
        }
    }

}
