//
//  UIImageEraseTests.swift
//  FotoMail
//
//  Created by Alistef on 04/05/2017.
//  Copyright © 2017 garfromDev. All rights reserved.
//

import XCTest


class UIImageEraseTests: XCTestCase {
    let size = CGSize(width: 100, height: 100)
    let p1 = CGPoint(x:20, y:20)
    let p2 = CGPoint(x:70, y:70)
    let thick = CGFloat(40)
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    /// test the class func erase from UIViewExtension
    func testErase() {
        //on crée une image verte
        let imgG = UIImage.createImage(with: UIColor.green, size:size)!
        
        // on crée une image rouge
        let imgR = UIImage.createImage(with: UIColor.red, size:size)!
        
        // les 2 images doivent êtres différentes
        XCTAssertFalse(imgG.isEqualToImage(image:imgR), "les 2 images doivent êtres différentes")


     }
    
    
}
