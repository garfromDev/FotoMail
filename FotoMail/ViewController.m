//
//  ViewController.m
//  FotoMail
//
//  Created by Alistef on 03/07/2016.
//  Copyright © 2016 garfromDev. All rights reserved.
//


// en version serial queue, 6 secondes entre cancel et présentation controleur pour conversion de 2 images prises rapidement, 4 s si prises lentement
#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController 
{
    NSMutableArray *images;
    NSString *toName;
    int imgNumber;
    UIImagePickerController *picker;
    dispatch_queue_t serialQueue;
    int nbImages;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    images = [[NSMutableArray alloc] init];
    serialQueue = dispatch_queue_create("GFD.FotoMail.queue", DISPATCH_QUEUE_SERIAL);
    toName = @"stephane.fromont@valeo.com";
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)photo:(id)sender {
    [self startCameraControllerFromViewController:self usingDelegate:self];
}


//--------------------------------------
#pragma mark Picture_Taking_part
//V2
- (void)prendPhoto
{

    [self startCameraControllerFromViewController:self usingDelegate:self];
}


- (BOOL) startCameraControllerFromViewController: (UIViewController*) controller
                                   usingDelegate: (id <UIImagePickerControllerDelegate,
                                                   UINavigationControllerDelegate>) delegate {
    
    if (([UIImagePickerController isSourceTypeAvailable:
          UIImagePickerControllerSourceTypeCamera] == NO)
        || (delegate == nil)
        || (controller == nil))
        return NO;
    
    
    UIImagePickerController *cameraUI = [[UIImagePickerController alloc] init];
    cameraUI.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    // Displays a control that allows the user to choose picture or
    // movie capture, if both are available:
    cameraUI.mediaTypes =
    [UIImagePickerController availableMediaTypesForSourceType:
     UIImagePickerControllerSourceTypeCamera];
    
    // Hides the controls for moving & scaling pictures, or for
    // trimming movies. To instead show the controls, use YES.
    cameraUI.allowsEditing = NO;
    
    cameraUI.delegate = delegate;
    
    [controller presentViewController: cameraUI animated: YES completion:nil];
    return YES;
}

//--------------------------------------
#pragma mark  Photo_Picker_Delegate
// OK V2
- (void)imagePickerController:(UIImagePickerController *) Picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    nbImages++;
    NSLog(@"récupération image %ul - %@", nbImages, [NSDate date]);
    __block UIImage *img;
    // 2 possibilités 1)dismisser et reafficher le controleur ou 2)ne pas dismisser le controleur et juste sauver l'image -> marche pas, les contrôles ne sont pas réaffiché
    img = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    dispatch_async( serialQueue,
                   ^{
                       NSLog(@"conversion asynchrone image %ul - %@",nbImages, [NSDate date]);
                      [images addObject: UIImagePNGRepresentation(img)];
                      NSLog(@"récup image finie %ul - %@",nbImages,[NSDate date]);
                  });
    [self dismissViewControllerAnimated:YES completion: ^{ [self prendPhoto]; } ];
    
    // ajouter un son ou une alerte pour confirmer enregistrement image?
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *) Picker
{   // l'utilisateur a annulé la prise de photo, on retire l'appareil et on passe au mail si une photo a été prise
    NSLog(@"cancel appuyé dans imagePicker");
    [self dismissViewControllerAnimated:YES completion:nil];
    if(nbImages == 0){
        NSLog(@"pas d'images, on fait rien");
        return;
    }
    [self displayComposerSheet];
}

//--------------------------------------
#pragma mark e-mail sending part

-(void)displayComposerSheet
{
    [self.activityIndicator startAnimating];
    if (![MFMailComposeViewController canSendMail]) {
        NSLog(@"Mail services are not available.");
        return;
    }
    //on prépare le composeur de mail
    NSLog(@"allocate Mail controller %@", [NSDate date]);
    MFMailComposeViewController *mailPicker = [[MFMailComposeViewController alloc] init];
    NSLog(@"lancement tache attachement image jointe %@", [NSDate date]);
    
    // on effectue l'ajout de l'image jointe sur un autre thread pour ne pas
    //bloquer l'interface utilisateur car la tache est longue
    // mais en synchro car il ne faut pas afficher le mail avant que l'image soit prête
    __block NSData *myData;
    dispatch_sync( serialQueue,
                  ^{
                      NSLog(@"début tache attachement des image %u ... %@", [images count], [NSDate date]);
                      for( int i = 0; i < [images count]; i++){
                          myData = UIImagePNGRepresentation(images[i]);
                          NSLog(@"attachement de l'image %u ... %@", i, [NSDate date]);
                          [mailPicker addAttachmentData:myData mimeType:@"image/png" fileName:[NSString stringWithFormat:@"Foto%u.png",imgNumber++]];
                      }
                      mailPicker.mailComposeDelegate = self;
                      [mailPicker setSubject:@"Fotomail:"];
                      
                      // Set up recipients
                      NSArray *toRecipients = [NSArray arrayWithObject:toName];
                      [mailPicker setToRecipients:toRecipients];
                      NSLog(@"fin de la tache d'attachement  %@",  [NSDate date]);
                  }
                  );
    // quand tout est prêt on affiche le mail
    NSLog(@"présente mail controller %@", [NSDate date]);
    [self presentViewController:mailPicker animated:YES completion:nil];
}


//--------------------------------------
#pragma mark e-mail delegate

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    // Notifies users about errors associated with the interface
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Result: canceled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Result: saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Result: sent");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Result: failed");
            break;
        default:
            NSLog(@"Result: not sent");
            break;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.activityIndicator stopAnimating];
    images = [[NSMutableArray alloc] init]; //on réinitialise le tableau d'images
    nbImages = 0;
    [self prendPhoto];
}

@end
