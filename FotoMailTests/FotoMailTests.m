//
//  FotoMailTests.m
//  FotoMailTests
//
//  Created by Alistef on 03/07/2016.
//  Copyright © 2016 garfromDev. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "FotomailUserDefault.h"
#import "ViewController.h"

@interface FotoMailTests : XCTestCase

@end

@implementation FotoMailTests
ViewController *myvc;

- (void)setUp {
    [super setUp];
    [FotomailUserDefault.defaults setImgNumber:0];

    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main"
                                                          bundle: [NSBundle mainBundle]];
    myvc = [storyboard instantiateInitialViewController];
    UIApplication.sharedApplication.keyWindow.rootViewController = myvc;
    
    // The One Weird Trick!
    UIView *_ = myvc.view; //charge la vue

    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

// may run on simulator
- (void)testViewDidLoad {
    
    UIScrollView * scrollView = (UIScrollView *)myvc.scrollView;
    for( UIGestureRecognizer *gr in scrollView.gestureRecognizers){
        if([gr isKindOfClass:[UIPanGestureRecognizer class]]){
            UIPanGestureRecognizer *pgr = (UIPanGestureRecognizer *)gr;
            XCTAssert(pgr.minimumNumberOfTouches == 2, @"The scrollView must be configured to use 2 finger scroll");
            return;
        }
    }
    XCTFail(@"No PanGestureRecognizer found in scrollView");

}


@end
