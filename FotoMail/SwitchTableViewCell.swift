//
//  SwitchTableViewCell.swift
//  FotoMail
//
//  Created by Alistef on 19/12/2016.
//  Copyright © 2016 garfromDev. All rights reserved.
//

import UIKit

/// cellule de type subtitle avec un switch en accessory view, identifier "SwitchTableViewCell"
///
/// l'action est paramétrable via le bloc valueDidChanged
@IBDesignable class SwitchTableViewCell: RoundImageTableViewCell {
    
    var sw: UISwitch
    
    /// le bloc de cette variable sera appellé à chaque changement de position du switch
    var valueDidChanged : (( UISwitch ) -> Void) = {
        (sw : UISwitch ) -> Void in
            // overridé par setting controller dans viewWillAppear
    }
    
    
    /// appellée par le mécanisme action/target du switch
    @objc func switchValueDidChange(_ sender:UISwitch){
        valueDidChanged(sender)
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.sw.isOn = FotomailUserDefault.defaults().timeStamp
    }

    
    init?(_ coder: NSCoder? = nil) {

        self.sw = UISwitch()

        if let coder = coder {
            super.init(coder: coder)
        } else {
            super.init(style: .subtitle, reuseIdentifier: "SwitchTableViewCell")
        }
        
        self.accessoryView = sw
        self.sw.addTarget(self, action: #selector( switchValueDidChange(_:) ), for: .valueChanged)
    }

    
    /// attention, le ruse identifier est systémaiquement écrasé
    override convenience init(style: UITableViewCell.CellStyle, reuseIdentifier: String?){
        self.init(nil)!
    }

    
    required convenience init?(coder aDecoder: NSCoder) {
        self.init(aDecoder)
    }

}
