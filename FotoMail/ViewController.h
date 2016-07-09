//
//  ViewController.h
//  FotoMail
//
//  Created by Alistef on 03/07/2016.
//  Copyright © 2016 garfromDev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@interface ViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate,  MFMailComposeViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UILabel *message;
- (IBAction)photo:(id)sender;

@end

