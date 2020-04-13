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

/**
    This mock camera will act like an extended camera (i.e.
    AbstractCameraDevice), have all flash mode available except Auto,
    ,return a fake image and trigger an expectation when torch is set off
*/
@interface MockCaptureDevice2: NSObject <AbstractCameraDevice>
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
- (void)captureUIImageWith:(AVCaptureVideoOrientation)orientation completion:(void (^)(UIImage *))imageHandler;
- (AVCaptureVideoPreviewLayer *)cameraLayer;

//parameters for testing :
/// this expectation will be fulfflilled when torch is set off
@property XCTestExpectation *torchOffExpectation;
@end

@implementation MockCaptureDevice2
BOOL _isTorchOn2 = false;
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
    _isTorchOn2 = true;
    return;
}
-(void)setTorchOff{
    LOG
    _isTorchOn2 = false;
    [self.torchOffExpectation fulfill];
    return;
}

-(BOOL)isTorchActive{
    return _isTorchOn2;
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
- (void)captureUIImageWith:(AVCaptureVideoOrientation)orientation completion:(void (^)(UIImage *))imageHandler {
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


/// redefinition of CameraManager protocol because not possible to import swift-h in objectiveC (BE CAREFULL if original declarion changes)
@protocol CameraManager
-(id<AbstractCameraDevice>)startCameraOnView:(UIView *)view;
-(void)checkCameraAuthorizationWithCompletion:(void(^)(BOOL granted))completionHandler;
@end


/** This mock camera manager will :
  - return a MockCaptureDevice for the camera
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
    return [[MockCaptureDevice2 alloc] init];
}
-(void)checkCameraAuthorizationWithCompletion:(void(^)(BOOL granted))completionHandler{
    completionHandler(self.granted);
    [[self authorizationAnsweredExpectation] fulfill];
}

@end


/** This mock object will always forbid access to mail
    CAUTION: it does not implement method of MFMailComposeViewController
    Do not try to use it for mail sending
*/
@interface MockMailManager:NSObject
+ (BOOL)canSendMail;
@end
@implementation MockMailManager
+ (BOOL)canSendMail{
    return false;
}
@end


/// we declare an extension on ViewControlelr to get access to overlayView for tetsing
@interface ViewController(UnitTest)
-(UIView *)overlayView;
@end

// we subclass ViewController to access the observer
@interface TestViewController:ViewController
@property XCTestExpectation *titreChangedExpectation;
@end

@implementation TestViewController

    - (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        if ([keyPath isEqualToString:@"nbImages"] || [keyPath isEqualToString:@"titreImg"]){
            [self.titreChangedExpectation fulfill];
        }
    }
@end



@interface FotoMailTests : XCTestCase
@end

@implementation FotoMailTests
TestViewController *myvc;
MockCaptureDevice2 *mockCamera;
MockCameraManager *mockCameraManager;

UIWindow *rootWindow;
XCTestExpectation *torchOffExpectation;
XCTestExpectation *authorizationAnsweredExpectation;
XCTestExpectation *nbImageChangedExpectation;

- (void)setUp {
    [super setUp];
    [FotomailUserDefault.defaults setImgNumber:0];

    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main"
                                                          bundle: [NSBundle mainBundle]];
    // thanks https://stackoverflow.com/questions/29669381/unit-test-swift-casting-view-controller-from-storyboard-not-working
    UIStoryboardViewControllerCreator creator = ^(NSCoder *coder){
        return [[TestViewController alloc] initWithCoder:coder];
    };
    if (@available(iOS 13.0, *)) {
        myvc = (TestViewController *)[storyboard instantiateInitialViewControllerWithCreator:creator];
    } else {
        XCTFail(@"This test must be run on iOS >= 13.0");
    }
    mockCameraManager = [[MockCameraManager alloc] init];
    myvc.cameraManager = mockCameraManager;
    
    rootWindow = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    [rootWindow setHidden:false];
    [rootWindow setRootViewController:myvc];
    
    // The One Weird Trick!
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Weverything"
    UIView *_ = myvc.view; //charge la vue
    #pragma clang diagnostic pop
    [myvc viewWillAppear:false];
    [myvc viewDidAppear:false];
    mockCamera  =  (MockCaptureDevice2 *)myvc.camera;
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
    myvc.mailComposerClass = [MFMailComposeViewController class];
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
    
    [mockCameraManager setGranted:false];
    authorizationAnsweredExpectation = [[XCTestExpectation alloc] initWithDescription:@"request for authorization must be answered"];
    mockCameraManager.authorizationAnsweredExpectation = authorizationAnsweredExpectation;
    [myvc viewDidLoad];
    NSLog(@"waiting authorizationAnsweredExpectation");
    [self waitForExpectations:@[authorizationAnsweredExpectation] timeout:5.0];
    XCTAssert([myvc.message.text isEqualToString:@"Camera usage not authorized\nChange Fotomail privacy setting for camera in Settings"],@"Message about camera not available must be displayed");
    XCTAssertTrue([myvc.overlayView isHidden],"Camera overlay view must be hidden");
}


-(void)testMailNotAuthorized{
    myvc.mailComposerClass = [MockMailManager class];
    [myvc viewDidLoad];
    XCTAssert([myvc.mailAvailabilityMessage.text isEqualToString:@"e-mail account not available"]);
}

-(void)testIncrementFotoName{
    nbImageChangedExpectation = [[XCTestExpectation alloc] initWithDescription:@"nbImage and Title must change through observer"];
    myvc.titreChangedExpectation = nbImageChangedExpectation;
    XCTAssertEqualObjects(myvc.titre.text, @"Foto_0.jpg", @"Le nom de l'image doit être Foto_0.jpg");
    XCTAssertEqualObjects(myvc.noPhoto.text, @"#1", @"1ere photo doit être afffiché");
    [myvc takePicture:nil];
    [self waitForExpectations:@[nbImageChangedExpectation] timeout:5.0];
    XCTAssertEqualObjects(myvc.titre.text, @"Foto_1.jpg", @"Le nom de l'image doit être Foto_1.jpg");
    XCTAssertEqualObjects(myvc.noPhoto.text, @"#2", @"2eme photo doit être afffiché");
}


/// helper function to turn the torch on by choosing the segmented control item
-(void) turnTorchOnThroughUI{
    UISegmentedControl *controls = myvc.flashControls;
    controls.selectedSegmentIndex = 2;
    [myvc choisiFlashMode:controls];
}
@end
