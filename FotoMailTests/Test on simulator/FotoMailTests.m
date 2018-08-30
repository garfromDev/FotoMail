//
//  FotoMailTests.m
//  FotoMailTests
//
//  Created by Alistef on 03/07/2016.
//  Copyright © 2016 garfromDev. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "ViewController.h"
#import "FotomailUserDefault.h"

#import <AVFoundation/AVFoundation.h>
#import "AVCaptureDevice+Extension.h"
#import "UIImage + createImageWithColor.h"


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

//parameters for testing :
@property XCTestExpectation *torchOffExpectation;
@end

@implementation MockCaptureDevice
BOOL _isTorchOn = false;
BOOL _granted = true;

/// always has torch available
-(BOOL) hasTorch{
    return true;
}

-(void)setFlashOff{
    [self setTorchOff];
    return;
}
-(void)setFlashAuto{
    [self setTorchOff];
    return;
}
-(void)setTorchOn{
    LOG
    _isTorchOn = true;
    return;
}
-(void)setTorchOff{
    LOG
    _isTorchOn = false;
    [self.torchOffExpectation fulfill];
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
/// return a faked image
-(void) captureUIImage: (void (^)(UIImage *image)) imageHandler{
    CGSize size = CGSizeMake(300.0, 300.0);
    UIImage *img = [UIImage createImageWithColor:UIColor.cyanColor size:size];
    imageHandler(img);
}

- (AVCaptureVideoPreviewLayer *)cameraLayer{
    return nil;
}

/// will always return false for flash mode auto, true for other mode
- (BOOL)isFlashModeSupported:(AVCaptureFlashMode)flashMode {
    return flashMode != AVCaptureFlashModeAuto;
}

@end

/// redefinition of CameraManager protocol because not possible to import swift-h in objectiveC
@protocol CameraManager
-(id<AbstractCameraDevice>)startCameraOnView:(UIView *)view;
-(void)checkCameraAuthorizationWithCompletion:(void(^)(BOOL granted))completionHandler;
@end


/** This mock camera manager will :
  - return a MOckCaptureDevice
  - return authorisation as defined by property "granted"
*/
@interface MockCameraManager:NSObject<CameraManager>
-(id<AbstractCameraDevice>)startCameraOnView:(UIView *)view;
-(void)checkCameraAuthorizationWithCompletion:(void(^)(BOOL granted))completionHandler;
@property  XCTestExpectation *authorizationAnsweredExpectation;
@property BOOL granted;

@end

@implementation MockCameraManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.granted = true;
    }
    return self;
}

-(id<AbstractCameraDevice>)startCameraOnView:(UIView *)view{
    return [[MockCaptureDevice alloc] init];
}
-(void)checkCameraAuthorizationWithCompletion:(void(^)(BOOL granted))completionHandler{
    completionHandler(self.granted);
    [[self authorizationAnsweredExpectation] fulfill];
}

@end



@interface FotoMailTests : XCTestCase

@end

@implementation FotoMailTests
ViewController *myvc;
MockCaptureDevice *mockCamera;
MockCameraManager *mockCameraManager;
UIWindow *rootWindow;
XCTestExpectation *torchOffExpectation;
XCTestExpectation *authorizationAnsweredExpectation;

- (void)setUp {
    [super setUp];
    [FotomailUserDefault.defaults setImgNumber:0];

    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main"
                                                          bundle: [NSBundle mainBundle]];
    // thanks https://stackoverflow.com/questions/29669381/unit-test-swift-casting-view-controller-from-storyboard-not-working
    myvc = (ViewController *)[storyboard instantiateInitialViewController];
    mockCameraManager = [[MockCameraManager alloc] init];
    myvc.cameraManager = mockCameraManager;
//    mockCamera  = [[MockCaptureDevice alloc] init];
//    myvc.camera = mockCamera;
    
    rootWindow = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    [rootWindow setHidden:false];
    [rootWindow setRootViewController:myvc];
    
    // The One Weird Trick!
    UIView *_ = myvc.view; //charge la vue
    [myvc viewWillAppear:false];
    [myvc viewDidAppear:false];
    mockCamera  =  (MockCaptureDevice *)myvc.camera;
    torchOffExpectation = [[XCTestExpectation alloc] initWithDescription:@"Torch must be off"];
    mockCamera.torchOffExpectation = torchOffExpectation;

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

/*
 FIXME: Le problème vient du fait que le viewController initialise les propriété
 camera dans le viewDidLoad, et donc écrase les propriétés que l'on lui injecte -> essayer de créer
 - (instancetype)initWithCoder:(NSCoder *)aDecoder; {
 [super initWithCoder: aDecoder];
 //your init code goes here.
 }
 et d'y initialisé le cameraManager ici (la camera sera initialisé à chechAuthorisation)
 */

-(void)testTorchOffByPreview{

    XCTAssert(mockCamera.isTorchActive==false,@"The torch must be off at start");
    
    [self turnTorchOnThroughUI];
    XCTAssert(mockCamera.isTorchActive,@"The torch must be activated by the segmented control");
    
    // appel à takeAndPreview va appeller capture image qui va appeler capture de la camera, puis appeler didFinishPickingMediaWithInf sur un bloc asynchrone, c'est lui qui éteint la torche
    // -> il faut rendr une image bidon via la mockcamera, et il faut utiliser une expectation
    [myvc takeAndPreview:nil];
    [self waitForExpectations:@[torchOffExpectation] timeout:6.0];
}

-(void)testTorchOffByMailSending{
    
    [self turnTorchOnThroughUI];
    XCTAssert(mockCamera.isTorchActive,@"The torch must be activated by the segmented control");
    
    [myvc envoiMail:nil];
    [self waitForExpectations:@[torchOffExpectation] timeout:6.0];
    
}


-(void)testFlashModeAutoNotAvailable{
    UISegmentedControl *controls = myvc.flashControls;
    XCTAssertFalse([controls isEnabledForSegmentAtIndex:1],"The segment for Flash auto must not be enabled when flash auto not available");
    XCTAssertTrue([controls isEnabledForSegmentAtIndex:0],"The segment for Flash off must be enabled when flash off available");
    XCTAssertTrue([controls isEnabledForSegmentAtIndex:2],"The segment for torch must be enabled when torch available");
}

-(void)testCameraNotAuthorized{
    // en fait, iln'y a pas de moyen de vérifier si l'interface de prise de vue a été caché car
    // il n'y a pas de propriété accessible sur l'overlay view
    // on peut vérifier le contenu du message
    // => à couvrir par un UI test pour test plus complet
    [mockCameraManager setGranted:false];
    authorizationAnsweredExpectation = [[XCTestExpectation alloc] initWithDescription:@"request for authorization must be answered"];
    mockCameraManager.authorizationAnsweredExpectation = authorizationAnsweredExpectation;
    [myvc viewDidLoad];
    NSLog(@"waiting authorizationAnsweredExpectation");
    [self waitForExpectations:@[authorizationAnsweredExpectation] timeout:5.0];
    XCTAssert([myvc.message.text isEqualToString:@"Camera usage not authorized\nChange Fotomail privacy setting for camera in Settings"],@"Message about camera not available must be displayed");
}

/// helper function to turn the torch on by choosing the segmented control item
-(void) turnTorchOnThroughUI{
    UISegmentedControl *controls = myvc.flashControls;
    controls.selectedSegmentIndex = 2;
    [myvc choisiFlashMode:controls];
}
@end
