//
//  UIViewControllerTest.m
//  FotoMailTests
//
//  Created by Alistef on 25/08/2018.
//  Copyright © 2018 garfromDev. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AVCaptureDevice+Extension.h"
#import "ViewController.h"

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
BOOL _isTorchOn;

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
@end


@interface UIViewControllerTest : XCTestCase

@end

@implementation UIViewControllerTest
ViewController *vc;

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    vc = [[ViewController alloc] initWithNibName:nil bundle:[NSBundle mainBundle]];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    MockCaptureDevice *mockCamera = [[MockCaptureDevice alloc] init];
    vc.camera = mockCamera;
    
}



@end
