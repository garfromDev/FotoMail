//
//  EditingImageViewTests.swift
//  FotoMail
//
//  Created by Alistef on 06/05/2017.
//  Copyright © 2017 garfromDev. All rights reserved.
//

import XCTest
@testable import FotoMail



class EditingImageViewTests: XCTestCase {
    var eiv : EditingImageView!
    let size = CGSize(width: 100, height: 100)
    var imgG, imgR : UIImage!
    
    override func setUp() {
        super.setUp()
        imgG = UIImage.createImage(withGradient:UIColor.green,
                                       color2: UIColor.blue,
                                       size: size)!
        imgR = UIImage.createImage(with: UIColor.red, size:size)!
        let rect = CGRect(origin: CGPoint.zero, size: size)
        eiv = EditingImageView(frame: rect)
        eiv.image = imgG
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testPrepareDisplay() {
        let imgAvant = eiv.image!
        XCTAssertNotNil(eiv.image, "Il doit y avoir une image")
        XCTAssert(imgG.isEqualToImage(image: eiv.image!), "L'image doit être celle transmise")
        let prepareEnded = expectation(description: "prepareEnded")
        eiv.prepareDisplay()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1,
                                      execute: { prepareEnded.fulfill()} )
        waitForExpectations(timeout: 2, handler: nil)
        XCTAssert(imgAvant.isEqualToImage(image: eiv.image!), "L'image ne doit pas être modifiée par PrepareDisplay()")
        
        eiv.undoEditing()
        let img2 = eiv.image!
        XCTAssert(imgAvant.isEqualToImage(image: eiv.image!), "L'image ne doit pas être modifiée par undoEditing()")
        
        let saved = expectation(description: "saved")
        eiv.saveEditedImage( { saved.fulfill() } )
        waitForExpectations(timeout: 1, handler: nil)
        XCTAssert(imgAvant.isEqualToImage(image: eiv.image!), "L'image ne doit pas être modifiée par saveEditingImage()")
        
        eiv.endDisplay()
        XCTAssert(imgAvant.isEqualToImage(image: eiv.image!), "L'image ne doit pas être modifiée par endDisplay()")
        
        //XCTAssertNotNil(eiv.getOriginaleImage(),"l'image originale doit exister après prepareDisplay()")
        //XCTAssert(imgAvant.isEqualToImage(image: eiv.getOriginaleImage()), " l'image originale doit être identique à image après PrepareDIsplay")
        
    }
    
    

    
}
