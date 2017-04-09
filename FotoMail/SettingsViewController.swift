//
//  SettingsViewController.swift
//  FotoMail
//
//  Created by Alistef on 18/12/2016.
//  Copyright © 2016 garfromDev. All rights reserved.
//

import UIKit
import ContactsUI

class SettingsViewController: UITableViewController {


    @IBOutlet weak var starImage: UIImageView!
    
    @IBOutlet weak var timeStampSwitchCell: SwitchTableViewCell!
    @IBOutlet weak var sizeTimeStampCell: SegmentedTableViewCell!
    @IBOutlet weak var reviewAppCell: RoundImageTableViewCell!
    
    
// MARK: initialisation
    override func viewDidLoad() {
        super.viewDidLoad()
        // on anime la ligne Review avec les images stars0 à stars5
        let imgs = (0...5).map{UIImage(named:"stars\($0)")!} + [UIImage(named:"stars5")!]
        starImage?.animationImages = imgs
        starImage?.animationDuration = 1.5
        starImage?.animationRepeatCount = 3
        
     }

    override func viewWillAppear(_ animated: Bool) {
        //on modifie le comportement pas défaut de timeStampSwitchCell
        timeStampSwitchCell.valueDidChanged = {
            (sw : UISwitch) in
            // désactive le choix de la taille si le timestamp est désactivé
            self.sizeTimeStampCell.isUserInteractionEnabled = sw.isOn
            self.sizeTimeStampCell.sw.isEnabled = sw.isOn
            
            // mémorize l'état
            FotomailUserDefault.defaults().timeStamp = sw.isOn
        }

    }
    
        
    
 // MARK: IBActions
    @IBAction func exitSettings(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    /// send the user to AppStore page for the app
    func reviewApp(){
        Reviewmanager.sharedInstance.performReview()
    }
    
    

    // MARK: UI personalisation
    //thanks to atticus http://stackoverflow.com/questions/31381762/swift-ios-8-change-font-title-of-section-in-a-tableview
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = UIColor.white
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let reviewIndex = tableView.indexPath(for: reviewAppCell)
        if(reviewIndex == indexPath){
            self.reviewApp()
        }
    }
    
    
    override var prefersStatusBarHidden: Bool {
        return false
    }

}
