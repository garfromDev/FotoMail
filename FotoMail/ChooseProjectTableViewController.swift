//
//  ChooseProjectTableViewController.swift
//  FotoMail
//
//  Created by Alistef on 01/10/2017.
//  Copyright © 2017 garfromDev. All rights reserved.
//

import UIKit

/**
Controller générique pour afficher le contenu d'un tableau de String
en mode overlay (avecd es coins arrondis)
*/
@objc class ChooseProjectTableViewController: StringArrayDisplayerViewController {}

class StringArrayDisplayerViewController: UITableViewController {

    @IBInspectable let identifier = "ChooseProjectIdentifier"
    @IBInspectable var radius : CGFloat = 20
    /// le tableau de String à afficher
    @objc var model : [NSString] = []
    
    /// l'action a faire lorsque une ligne est sélectionnée
    @objc var didSelect = { (index:NSInteger, content:NSString) -> Void in}
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.layer.cornerRadius = radius
    }

    /// le menu disparait quand on tape à l'extérieur, à brancher sur un
    // gesture recognizer
    @IBAction func TapOutside(_ sender: UITapGestureRecognizer) {
        print("TapOuside project list controler")
        self.dismiss(animated: true, completion: nil)
    }
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // 1 seule section
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)

        // Configure the cell...
        cell.textLabel?.text = String(describing:model[indexPath.row])
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("didSelectRowAt")
        didSelect(NSInteger(indexPath.row), model[indexPath.row])
        self.dismiss(animated: true, completion: nil)
    }
    

}


