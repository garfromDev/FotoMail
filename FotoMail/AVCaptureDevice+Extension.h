//
//  AVCaptureDevice+Extension.h
//  FotoMail
//
//  Created by Alistef on 11/02/2017.
//  Copyright © 2017 garfromDev. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>

extern NSString *kcameraControlsMacroModeChangedNotification;
extern NSString *UserControlsErrorDomain;

/// les codes d'erreurs du framework
enum {
    AVCaptureSessionPresetPhotoNotAvailable,
    backCameraNotFound,
    unableToAddIputOrOutputToCaptureSession
};

/// define a partial abstract interface for AVCaptureDevice in order to replace by another object as needed
@protocol AbstractCameraDevice
@property(nonatomic, readonly) BOOL hasTorch;
@property(nonatomic, readonly, getter=isTorchActive) BOOL torchActive NS_AVAILABLE_IOS(6_0);
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

/// add usefull method to control torch and flash mode and for picture preview and picture taking
@interface AVCaptureDevice (UserControls)

/*! create a captureDevice instance with preview in the view
 @param view : the UIView where the preview will be displayed
 @return the AVCaptureDevice instance initialized for still image capture, nil if not possible to create
 @discussion the preview is added as sublayer of view
 @code camera = [AVCaptureDevice initCameraOnView:self.cameraPreviewView];
 @endcode
 */
+ (AVCaptureDevice *) initCameraOnView: (UIView *)view error:(NSError **)outError;

/*! the AVCaptureVideoPreviewLayer for this captureDevcie instance
 @param
 @return the AVCaptureVideoPreviewLayer for this captureDevcie instance
 @discussion Utilisation : if it is needed to get access to the layer
 @code
 @endcode
 */
- (AVCaptureVideoPreviewLayer *)cameraLayer;

/*! check the authorisation to use the camera.
    user will be asked if not already done
 @param the handler that will be called with the status (after user answer or immediatly if status already known)
 @return
 @discussion the handler is called on main queue
 @code
 [AVCaptureDevice checkCameraAuthorizationWithCompletion:^(BOOL granted) {
    if(granted){
        [self setAuthorized];
    }else{
        [self setNonAuthorized];
    }
 }];
 @endcode
 */
+(void) checkCameraAuthorizationWithCompletion: (void(^)(BOOL granted))completionHandler;

/*! set the focus to a specific point
 @param pointInPreview is the position of the point in the preview view
 @return
 @discussion disabled macro mode if it is enabled. 
 Nothing happen if focus setting not available
 @code CGPoint pointInPreview = [sender locationInView:sender.view];
 [camera setFocusToPoint:pointInPreview];
 @endcode
 */
-(void) setFocusToPoint: (CGPoint) pointInPreview;

/*! capture asynchronously a still image
 @param the handler that will receive the captured image
 @return UIImage is transmitted to the handler, may be nil if problem
 @discussion there is no commitment on which thread/queu the handler is called
 it should dispatch on main queue if UI uptading is necessary
 in case of error,  the handler is  called with a nil parameter
 @code
 @endcode
 */
-(void) captureUIImage: (void (^)(UIImage *image)) imageHandler;


/// return true if the device has capability for macro mode
-(BOOL) isMacroAvailable;

/// returns true if the macro mode is on. False if macro mode not available
-(BOOL) isMacroOn;

/*! set the focus to closest distance with fixed focus
 @param
 @return
 @discussion does nothing is focus setting not available
 @code
 @endcode
 */
-(void)setMacroOn;

/*! returns to automatic focus
 @param
 @return
 @discussion does nothing is focus setting not available
 @code
 @endcode
 */
-(void)setMacroOff;

/*! switch on the torch (if available)
 @param
 @return
 @discussion the flash mode is set to Off
 @code
 @endcode
 */
-(void)setTorchOn;

/*! switch off the torch (if available)
 @param
 @return
 @discussion the flash mode is unchanged
 @code
 @endcode
 */
-(void)setTorchOff;

/*! switch off the flash (if available)
 @param
 @return
 @discussion the torch is switch off
 @code
 @endcode
 */
-(void)setFlashOff;

/*! switch the flash to auto (if available)
 @param
 @return
 @discussion the torch is switch off
 @code
 @endcode
 */
-(void)setFlashAuto;

@end
