//
//  AVCaptureDevice+ExtensionFaultTests.m
//  FotoMail
//
//  Created by Alistef on 12/08/2017.
//  Copyright © 2017 garfromDev. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <AVFoundation/AVFoundation.h>
#import "AVCaptureDevice+Extension.h"
#import "AVCaptureSession+extension.h"

@interface AVCaptureDevice_ExtensionFaultTests : XCTestCase

@end

/// Le but de ce test est de vérifier la branche d'erreur de initCameraWithView: en cas de réponse négative de canSetSessionPreset
/// pour cela une réponse négative est injéctée par la catégorie appliquée  à AVCaptureSession dans AVCaptureSession+extension
/// PEUT ETRE EXECUTE SUR SIMULATEUR
@implementation AVCaptureDevice_ExtensionFaultTests


- (void)setUp {
    [super setUp];
    
    
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testCannotSetSessionPreset {
    UIViewController *vc = [[UIViewController alloc] init];
    UIApplication.sharedApplication.keyWindow.rootViewController = vc;
    UIWindow *rootWindow;
    rootWindow = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    [rootWindow setHidden:false];
    [rootWindow setRootViewController:vc];
    UIView *myView = [[UIView alloc] initWithFrame:vc.view.bounds];
    [vc.view addSubview:myView];
    NSError *error = [[NSError alloc] init];
    AVCaptureDevice *camera = [AVCaptureDevice initCameraOnView:myView error:&error];
    XCTAssert(camera == nil, @"L'initialisation doit avoir échouée");
   // XCTAssert(error.domain == UserControlsErrorDomain, @"L'erreur remontée doit être dans UserControlsErrorDomain");
    XCTAssert(error.code == AVCaptureSessionPresetPhotoNotAvailable, @"L'erreur remontée doit avoir pour code AVCaptureSessionPresetPhotoNotAvailable");
    XCTAssert([error.userInfo[@"NSLocalizedDescription"] isEqualToString: @"AVCaptureSessionPresetPhoto not available"], @"L'erreur remontée doit être AVCaptureSessionPresetPhoto not available");
}


@end
