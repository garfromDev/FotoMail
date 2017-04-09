//
//  Recipients_CNContactPickerDelegate.swift
//  FotoMail
//
//  Created by Alistef on 21/12/2016.
//  Copyright © 2016 garfromDev. All rights reserved.
//

import UIKit
import ContactsUI

@available(iOS 9, *)
extension RecipientsTableViewController: CNContactPickerDelegate {
    
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contactProperty: CNContactProperty) {
        changeContentOfRow(editedRow: editedRow, by: contactProperty.value as! String)
    }

}
