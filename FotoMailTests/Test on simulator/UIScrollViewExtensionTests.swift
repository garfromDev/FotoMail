//
//  UIScrollViewExtensionTests.swift
//  FotoMail
//
//  Created by Alistef on 29/03/2017.
//  Copyright © 2017 garfromDev. All rights reserved.
//

import XCTest


//  run on simulator
class UIScrollViewExtensionTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    // nominal case
    func testConfigureFor2FingersScroll() {
        let scr = UIScrollView()
        scr.configureFor2FingersScroll()
        for gr in scr.gestureRecognizers! {
            if gr.isKind(of:UIPanGestureRecognizer.self) {
                let pgr = gr as! UIPanGestureRecognizer
                XCTAssert(pgr.minimumNumberOfTouches == 2, "ScrollView must be configuered to use 2 fingers scroll")
                return
            }
        }
        XCTFail("No PanGestureRecognizer found in scrollView")
        
    }
    
    // no GestureRecognizers
    func testConfigureNoGestureRecognizers(){
        let scr = UIScrollView()
        scr.gestureRecognizers = nil
        scr.configureFor2FingersScroll()
        // not fail is expected
        
    }
    
    // no PanGestureRecognizers
    func testConfigureNoPangesture() {
        let scr = UIScrollView()
        for (index, gr) in scr.gestureRecognizers!.enumerated() {
            if gr.isKind(of:UIPanGestureRecognizer.self) {
                scr.gestureRecognizers!.remove(at: index)
            }
        }
        scr.configureFor2FingersScroll()
        // not fail is expected

    }
    
    
}
