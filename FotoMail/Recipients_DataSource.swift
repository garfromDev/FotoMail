//
//  Recipients_DataSource.swift
//  FotoMail
//
//  Created by Alistef on 21/12/2016.
//  Copyright © 2016 garfromDev. All rights reserved.
//

import UIKit

// Protocole UITableViewControllerDataSource
extension RecipientsTableViewController  {

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : EmailEditableTableViewCell = (tableView.dequeueReusableCell(withIdentifier: "email", for: indexPath) as? EmailEditableTableViewCell)!
        cell.textField.delegate = self
        cell.textField.text = emailAdress[indexPath.row]
        cell.textField.placeholder = "Enter email adress"
        cell.textField.tag = indexPath.row
        cell.contactButton.tag = indexPath.row
        cell.contactButton.addTarget(self, action: #selector(chooseContact(_:)), for: UIControl.Event.touchUpInside)
        cell.textField.tag =  indexPath.row
        return cell
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return emailAdress.count
    }
    
    
}
