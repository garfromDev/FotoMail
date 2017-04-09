//
//  SegmentedTableViewCell.swift
//  FotoMail
//
//  Created by Alistef on 31/12/2016.
//  Copyright © 2016 garfromDev. All rights reserved.
//

import UIKit

/// cellule de type subtitle avec un segmentedControl en accessory view, identifier "SegmentedTableViewCell"
///
/// l'action est paramétrable via les blocs valueDidChanged et indexToSelect
class SegmentedTableViewCell: RoundImageTableViewCell {
    
    var sw: UISegmentedControl!
    /// le bloc de cette variable sera appellé à chaque changement de position du switch
    var valueDidChanged : (( UISegmentedControl ) -> Void) = {
        (sw : UISegmentedControl ) -> Void in
        
        //on enregistre la taille choisie
        let index = sw.selectedSegmentIndex
        let size = [ SMALL , MEDIUM , LARGE][index]
        FotomailUserDefault.defaults().stampSize = size
    }
    
    
    var indexToSelect : ((Void) -> Int) = {
        
        let size = FotomailUserDefault.defaults().stampSize
        if let index = [ SMALL , MEDIUM , LARGE].index(of: size){
            return Int(index)
        }
        
        return 1
    }
    
    
    /// appellée par le mécanisme action/target du switch
    func switchValueDidChange(_ sender:UISegmentedControl){
        valueDidChanged(sender)
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.sw.selectedSegmentIndex = self.indexToSelect()

    }
    
    
    init?(_ coder: NSCoder? = nil) {
        
        self.sw = UISegmentedControl(items:["48", "96", "160"])
        
        if let coder = coder {
            super.init(coder: coder)
        } else {
            super.init(style: .subtitle, reuseIdentifier: "SegmentedTableViewCell")
        }
        
        self.accessoryView = sw
        self.sw.addTarget(self, action: #selector( switchValueDidChange(_:) ), for: .valueChanged)
    }
    
    
    /// attention, le reuse identifier est systémaiquement écrasé
    override convenience init(style: UITableViewCellStyle, reuseIdentifier: String?){
        self.init(nil)!
    }
    
    
    required convenience init?(coder aDecoder: NSCoder) {
        self.init(aDecoder)
    }
    
}