//
//  AVCaptureDevice+ExtensionTests.m
//  FotoMail
//
//  Created by Alistef on 11/02/2017.
//  Copyright © 2017 garfromDev. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <AVFoundation/AVFoundation.h>
#import "AVCaptureDevice+Extension.h"

@interface AVCaptureDevice_ExtensionTests : XCTestCase

@end

/// doit être exécuté sur DEVICE
@implementation AVCaptureDevice_ExtensionTests

AVCaptureDevice *camera;

- (void)setUp {
    [super setUp];
    
    camera = nil;
    NSArray<AVCaptureDevice*>* devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    // Select back camera
    for (AVCaptureDevice *device in devices) {
        if ([device position]==AVCaptureDevicePositionBack) {
            camera = device;
            break;
        }
    }
    
    XCTAssert(camera != nil, @"test must be run on device to have camera available");
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}


- (void)testMacroOn {
    /* 
     la valeur initial doit être macroOff
     un appel à setMacroOff doit rester Off
     un appel à setMacroOn doit passer On
     un appel à setMacroOn doit rester On
     un appel à setMacroOff doit passer Off
     */
    XCTAssertFalse(camera.isMacroOn, @"la valeur initial doit être macroOff");
    [camera setMacroOff];
    XCTAssertFalse(camera.isMacroOn, @"un appel à setMacroOff doit rester Off");
    [camera setMacroOn];
    XCTAssertTrue(camera.isMacroOn, @"un appel à setMacroOn doit passer On");
    [camera setMacroOn];
    XCTAssertTrue(camera.isMacroOn, @"un appel à setMacroOn doit rester On");
    [camera setMacroOff];
    XCTAssertFalse(camera.isMacroOn, @"un appel à setMacroOff doit passer Off");
}


@end
