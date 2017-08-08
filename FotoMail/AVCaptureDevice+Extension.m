//
//  AVCaptureDevice+Extension.m
//  FotoMail
//
//  Created by Alistef on 11/02/2017.
//  Copyright © 2017 garfromDev. All rights reserved.
//

#import "AVCaptureDevice+Extension.h"
#import "defines.h"
#import "FotoMail-Swift.h"

/// this notification is send when the macro mode change
NSString *kcameraControlsMacroModeChangedNotification = @"kcameraControlsMacroModeChangedNotification";

/// error domain for all errors issued by this framework
NSString *UserControlsErrorDomain = @"com.garfromDev.AVCaptureDeviceUserControls.ErrorDomain";

@implementation AVCaptureDevice (UserControls)
/// memorize the state of macro
static BOOL _isMacroOn;
/// la queue pour le controle de l'apareil photo
static dispatch_queue_t _sessionQueue ;

/// le device de prise d'image
AVCaptureDevice *camera;
/// le flux de sortie image
AVCaptureStillImageOutput *imageOutput;
/// la layer de la vue caméra
AVCaptureVideoPreviewLayer *cameraLayer;

#pragma mark Initialisation and usefull properties
/// internal class method : the session queue to use for sending action to the AvCaptureDevice
+ (dispatch_queue_t) sessionQueue {
    // note : method class because it is needed before creating the instance of AVCaptureDevice
    if(_sessionQueue == nil){
        _sessionQueue = dispatch_queue_create("com.gfd.camera.capture/session", DISPATCH_QUEUE_SERIAL);
    }
    return _sessionQueue;
}


- (AVCaptureVideoPreviewLayer *)cameraLayer{
    return cameraLayer;
}


+ (AVCaptureDevice *) initCameraOnView: (UIView *)view error:(NSError **)outError{
    LOG
    AVCaptureSession *captureSesion = [[AVCaptureSession alloc] init];
    if (![captureSesion canSetSessionPreset:AVCaptureSessionPresetPhoto]) { //FIXME normalement AVCaptureSessionPresetPhoto, mis medium pour baisser la conso mémoire
        if(outError!=nil){
            *outError = [NSError errorWithDomain:UserControlsErrorDomain
                    code: AVCaptureSessionPresetPhotoNotAvailable
                    userInfo:@{NSLocalizedDescriptionKey:@"AVCaptureSessionPresetPhoto not available"} ];
        }
        return nil;
    }
    camera = nil;
    NSArray<AVCaptureDevice*>* devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    // Select back camera
    for (AVCaptureDevice *device in devices) {
        if ([device position]==AVCaptureDevicePositionBack) {
            camera = device;
            break;
        }
    }
    if (camera == nil) {
        // Back camera not found.
        if(outError!=nil){
            *outError = [NSError errorWithDomain:UserControlsErrorDomain
                                            code: backCameraNotFound
                                        userInfo:@{NSLocalizedDescriptionKey:@"Back camera not available"} ];
        }
        return nil;
    }
    
    imageOutput = [[AVCaptureStillImageOutput alloc]init];
    [imageOutput setOutputSettings: @{AVVideoCodecKey: AVVideoCodecJPEG}];
    NSError *error;
    //AVCaptureDeviceInput *deviceInput = [[AVCaptureDeviceInput alloc]initWithDevice:camera error: &error];
    AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:camera error:&error];
    if (error){
        if(outError) { *outError = error ;}
        return nil;
    }
    if (![captureSesion canAddInput:deviceInput] || ![captureSesion canAddOutput:imageOutput]) {
        if(outError!=nil){
            *outError = [NSError errorWithDomain:UserControlsErrorDomain
                                            code: unableToAddIputOrOutputToCaptureSession
                                        userInfo:@{NSLocalizedDescriptionKey:@"unable to add input or output to capture session"} ];
        }
        return nil;
    }
    [captureSesion addInput:deviceInput];
    [captureSesion addOutput:imageOutput];
    
    cameraLayer = [[AVCaptureVideoPreviewLayer alloc]initWithSession:captureSesion];
    // "Aspect Fill" is suitable for fullscreen camera.
    cameraLayer.frame = view.bounds;
    cameraLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [view.layer addSublayer:cameraLayer];
    dispatch_async([self sessionQueue],  ^{ //les appels à session sont bloquants
        [captureSesion setSessionPreset:AVCaptureSessionPresetPhoto]; //FIXME pour réduire la conso mémoire
        [captureSesion startRunning];
    });
    
    return camera;
}

#pragma mark Image capture
-(void) captureUIImage: (void (^)(UIImage *image)) imageHandler{
    // capture asynchrone pour ne pas bloquer
    dispatch_async([AVCaptureDevice sessionQueue], ^{
        NSLog(@"takePicture - capturing image...");
        AVCaptureConnection *connexion = [imageOutput connectionWithMediaType:AVMediaTypeVideo];
        if(connexion==nil){
            imageHandler(nil);
            return;
        }
        
        // pas compris pourquoi, mail il faut la garder ici sinon la photo est mal orienté een paysage
        connexion.videoOrientation = [orientationHelper convertInterfaceOrientationToAVCatureVideoOrientationWithUi:[[UIApplication sharedApplication] statusBarOrientation]];
        [imageOutput captureStillImageAsynchronouslyFromConnection:connexion completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
            NSLog(@"takePicture - image captured error:%@", error.description);
            if(error){
                imageHandler(nil);
                return;
            }
            
            NSData *imageData;
            @try{
                imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
            }
            @catch(NSException *theException){
                NSLog(@"An exception occurred: %@", theException.name);
                NSLog(@"Here are some details: %@", theException.reason);
                imageHandler(nil);
                return;
            }
            UIImage *stillImg = [UIImage imageWithData:imageData]; //may be nil if conversion problem
            NSLog(@"takePicture - image captured img:%@", stillImg);
            imageHandler(stillImg);
        }];
    });
    
}


#pragma mark Focus management
-(BOOL) isMacroOn{
    return _isMacroOn;
}


-(BOOL) isMacroAvailable{
    return [camera isFocusModeSupported:AVCaptureFocusModeLocked];
}


-(void)setMacroOn{
    [self configure: ^{
        if(![camera isFocusModeSupported:AVCaptureFocusModeLocked]) {return;}
        
        [camera setFocusModeLockedWithLensPosition:0.0 completionHandler:nil];
        _isMacroOn = true;
        [self notifyMacroModeChange];
        }
     ];
}


-(void)setMacroOff{
    [self configure: ^{
        if(![camera isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {return;}
        
        [camera setFocusMode: AVCaptureFocusModeAutoFocus];
        _isMacroOn = false;
        [self notifyMacroModeChange];
        }
    ];
}


-(void) setFocusToPoint: (CGPoint) pointInPreview{
    CGPoint pointInCamera = [cameraLayer captureDevicePointOfInterestForPoint:pointInPreview];
    
    // désactive le mode macro si il était actif
    [self setMacroOff];
    
    [self configure: ^{
        self.focusPointOfInterest = pointInCamera;
        self.focusMode = AVCaptureFocusModeAutoFocus;
    }
     ];
}


-(void) notifyMacroModeChange{
    [[NSNotificationCenter defaultCenter] postNotificationName: kcameraControlsMacroModeChangedNotification object: self];
}


#pragma mark Torch and flash
-(void)setTorchOn{
    if( ![self isTorchModeSupported:AVCaptureTorchModeOn]) {return;}
    
    [self configure: ^{
        [self setFlashOff];
        camera.torchMode = AVCaptureTorchModeOn;
    }
     ];
}


-(void)setTorchOff
{
    if( ![self isTorchModeSupported:AVCaptureTorchModeOff]) {return;}
    
    [self configure: ^{
        camera.torchMode = AVCaptureTorchModeOff;
    }
     ];
}


-(void)setFlashOff
{
    if(![self isFlashModeSupported:AVCaptureFlashModeOff]) {return;}
    
    [self configure: ^{
        [self setTorchOff];
        camera.flashMode = AVCaptureFlashModeOff;
    }
     ];
}


-(void)setFlashAuto
{
    if(![self isFlashModeSupported:AVCaptureFlashModeAuto]) {return;}
    
    [self configure: ^{
        [self setTorchOff];
        camera.flashMode = AVCaptureFlashModeAuto;
    }
     ];
}

+(void) checkCameraAuthorizationWithCompletion: (void(^)(BOOL granted))completionHandler
{ LOG
    AVAuthorizationStatus auth = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    
    //on crée un bloc local pour faire le callback sur le main queue
    __block void(^handler)(BOOL granted) = ^(BOOL granted){
        dispatch_async(dispatch_get_main_queue(), ^{
            completionHandler(granted);
        });
    };
    
    switch (auth) {
        case AVAuthorizationStatusNotDetermined:
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo
                            completionHandler:handler
            ];
            break;
            
        case AVAuthorizationStatusAuthorized:
            handler(true);
            break;
            
        case AVAuthorizationStatusDenied:
            handler(false);
            break;
        
        case AVAuthorizationStatusRestricted:
            break; //normalement jamais appellé
            
    }

}


#pragma mark Internal method
/*! effectue une action de configuration en gérant le verouillage/déverouillage
 @param the block with the configuration change actions
 @return
 @discussion does nothing is cannot lock configuration
 @code
 [self configure: ^{
    [self setTorchOff];
    camera.flashMode = AVCaptureFlashModeAuto;
 }
 ];
 @endcode
 */
-(void)configure: (void (^)())action{
    NSError *error;
    // il faut verouiller le device avant de changer sa config
    if( ![camera lockForConfiguration:&error]) { return;}
    
    action();
    
    // on déverouille le device
    [camera unlockForConfiguration];
}
@end
