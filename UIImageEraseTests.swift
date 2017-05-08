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
        
        //on crée un contexte
        UIGraphicsBeginImageContext(size)
        let context = UIGraphicsGetCurrentContext()!
        
        //on y dessine l'image verte
        imgG.draw(at:CGPoint.zero)
        let imgAvant = UIGraphicsGetImageFromCurrentImageContext()!


        // on gomme une partie de l'image verte avec la gomme rouge
        UIView.erase(from:p1, to:p2, thickness:thick, context:context, rubberImg:imgR)
        let imgGommee2 = UIGraphicsGetImageFromCurrentImageContext()!
//        context.restoreGState()
       XCTAssertFalse(imgAvant.isEqualToImage(image:imgGommee2),"l'image gommée par du rouge ne doit plus être verte")
        
        //on gomme le rouge avec du vert
        UIView.erase(from:p1, to:p2, thickness:thick, context:context, rubberImg:imgG)
        let imgGommee = UIGraphicsGetImageFromCurrentImageContext()!
        XCTAssert(imgAvant.isEqualToImage(image:imgGommee),"l'image gommée par du vert doit  être à nouveau verte")
        UIGraphicsEndImageContext()
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
