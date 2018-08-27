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


#import <AVFoundation/AVFoundation.h>
#import "AVCaptureDevice+Extension.h"
@interface MockCaptureDevice: NSObject <AbstractCameraDevice>
@property(nonatomic, readonly) BOOL hasTorch;
@property(nonatomic, readonly, getter=isTorchActive) BOOL torchActive NS_AVAILABLE_IOS(6_0);
@property(nonatomic, readonly, getter=isFlashAvailable) BOOL flashAvailable;
- (BOOL)isFlashModeSupported:(AVCaptureFlashMode)flashMode;
-(void)setFlashOff;
-(void)setFlashAuto;
-(void)setTorchOn;
-(void)setTorchOff;
-(BOOL) isMacroAvailable;
-(void)setMacroOn;
-(void)setMacroOff;
-(BOOL) isMacroOn;
-(void) setFocusToPoint: (CGPoint) pointInPreview;
-(void) captureUIImage: (void (^)(UIImage *image)) imageHandler;
- (AVCaptureVideoPreviewLayer *)cameraLayer;
@end

@implementation MockCaptureDevice
BOOL _isTorchOn = false;

-(void)setFlashOff{
    return;
}
-(void)setFlashAuto{
    return;
}
-(void)setTorchOn{
    _isTorchOn = true;
    return;
}
-(void)setTorchOff{
    _isTorchOn = false;
    return;
}

-(BOOL)isTorchActive{
    return _isTorchOn;
}

-(BOOL) isMacroAvailable{
    return true;
}
-(void)setMacroOn{
    return;
}
-(void)setMacroOff{
    return;
}
-(BOOL) isMacroOn{
    return true;
}
-(void) setFocusToPoint: (CGPoint) pointInPreview{
    return;
}
-(void) captureUIImage: (void (^)(UIImage *image)) imageHandler{
    return;
}
- (AVCaptureVideoPreviewLayer *)cameraLayer{
    return nil;
}

- (BOOL)isFlashModeSupported:(AVCaptureFlashMode)flashMode {
    return true;
}

@end


@interface FotoMailTests : XCTestCase

@end

@implementation FotoMailTests
ViewController *myvc;
UIWindow *rootWindow;

- (void)setUp {
    [super setUp];
    [FotomailUserDefault.defaults setImgNumber:0];

    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main"
                                                          bundle: [NSBundle mainBundle]];
    // thanks https://stackoverflow.com/questions/29669381/unit-test-swift-casting-view-controller-from-storyboard-not-working
    myvc = (ViewController *)[storyboard instantiateInitialViewController];
    myvc.camera = [[MockCaptureDevice alloc] init];
    rootWindow = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    [rootWindow setHidden:false];
    [rootWindow setRootViewController:myvc];
    
    // The One Weird Trick!
    UIView *_ = myvc.view; //charge la vue
    [myvc viewWillAppear:false];
    [myvc viewDidAppear:false];

}

- (void)tearDown {
    [myvc viewWillDisappear:false];
    [myvc viewDidDisappear:false];
    [rootWindow setRootViewController:nil];
    myvc = nil;
    [rootWindow setHidden:true];
    rootWindow = nil;
    [super tearDown];
}

// run on simulator
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


-(void)testTorchOff{
    
    UISegmentedControl *controls = myvc.flashControls;
    
}

@end
