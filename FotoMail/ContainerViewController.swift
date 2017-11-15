//
//  ContainerViewController.swift
//  FotoMail
//
//  Created by Alistef on 13/11/2017.
//  Copyright © 2017 garfromDev. All rights reserved.
//

import UIKit
/**
    Cette classe défini un ViewController qui inclu une ContainerView
 qui est exposé en tant qu'outlet pour pouvoir :
 1) raccorder l'outlet dans Storyboard
 2) accéder au viewCOntroller de la containerView depuis le viewController
    qui instancie ce ContainerViewController
*/
@objc class ContainerViewController: UIViewController {
    // ces 2 propriétés servent à exposer vers le viewCOntroller appelant
    // les propriétés du ChooseProjectTableViewCOntroller qui n'est pas
    // encore instancié dans le prepare segue du ContainerViewCOntroller
    @objc var model : [NSString] = []
    @objc var didSelect = { (index:NSInteger, content:NSString) -> Void in}
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    // thanks to Peter E https://stackoverflow.com/questions/13279105/access-container-view-controller-from-parent-ios
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("prepare(for segue")
        guard let segID = segue.identifier else {return}
        if segID == "EmbedChooseProjectView" {
            let containerController = segue.destination as! ChooseProjectTableViewController
            containerController.model = model
            containerController.didSelect = didSelect
        }
    }
    
    @IBAction func TapOutside(_ sender: UITapGestureRecognizer) {
        print("TapOuside project list controler")
        self.dismiss(animated: true, completion: nil)
    }
    
}
