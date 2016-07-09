//
//  ViewController.m
//  FotoMail
//
//  Created by Alistef on 03/07/2016.
//  Copyright © 2016 garfromDev. All rights reserved.
//

// utile: pouvoir choisir le nom fichier de base

// en version serial queue, 6 secondes entre cancel et présentation controleur pour conversion de 2 images prises rapidement, 4 s si prises lentement
#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController 
{
    NSMutableArray *images;
    NSString *toName;
    NSString *subject;
    int imgNumber;
    UIImagePickerController *picker;
    dispatch_queue_t serialQueue;
    int nbImages;
    dispatch_group_t mailGroup, imgGroup;
    MFMailComposeViewController *mailPicker;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    images = [[NSMutableArray alloc] init];
    serialQueue = dispatch_queue_create("GFD.FotoMail.queue", DISPATCH_QUEUE_SERIAL);
    toName = @"alistef@laposte.net";
    subject = @"FotoMail";
    imgGroup = dispatch_group_create();
    mailGroup = dispatch_group_create();
    [self preparePhoto];
//    toName = @"stephane.fromont@valeo.com";

}

-(void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if(![[self activityIndicator] isAnimating]) {
        [self photo:self];
    };
}


- (IBAction)photo:(id)sender {
    [[self message] setText:@""];
    [self startCameraControllerFromViewController:self usingDelegate:self];
}


//--------------------------------------
#pragma mark Picture_Taking_part

- (void)preparePhoto
{
    nbImages = 0;
    // on fait la préparation du controleur de mail en tache de fond pour afficher le plus vite possible l'appareil photo
    // on utilise le groupe mailGroup pour ne pas lancer d'attachement d'image avant que le controlleur ne soit crée
    dispatch_group_async(mailGroup, dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0),
    ^{ //on prépare le composeur de mail
        NSLog(@"allocate Mail controller %@", [NSDate date]);
        mailPicker = [[MFMailComposeViewController alloc] init];
        mailPicker.mailComposeDelegate = self;
        [mailPicker setSubject:subject];
        // Set up recipients
        NSArray *toRecipients = [NSArray arrayWithObject:toName];
        [mailPicker setToRecipients:toRecipients];
    } );
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
// Une image a été choisie, on l'ajoute en pièce jointe au mail, on dismiss l'appareil photo pour le rafficher aussitot
- (void)imagePickerController:(UIImagePickerController *) Picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    nbImages++;
    NSLog(@"récupération image %u - %@", nbImages, [NSDate date]);
    __block UIImage *img;

    [[self message] setText:@"sauvegarde de l'image"];
    img = [info objectForKey:UIImagePickerControllerOriginalImage];
    // on effectue en tache de fond la transformation et l'attachement de l'image
    // le imgGroup permet d'attendre la fin de tous les attachements avant d'afficher le mail composer
    dispatch_group_notify(mailGroup, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0),
                          ^{
                              dispatch_group_async(imgGroup, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0),
                                                   ^{
                                                       NSLog(@"conversion asynchrone image %u - %@",nbImages, [NSDate date]);
//                                                       NSData * myData = UIImagePNGRepresentation(img);
                                                       NSData * myData = UIImageJPEGRepresentation(img, 1.0);
                                                       NSLog(@"conversion image finie %u - %@",nbImages,[NSDate date]);
                                                       NSLog(@"attachement de l'image %u ... %@", nbImages, [NSDate date]);
//                                                       [mailPicker addAttachmentData:myData mimeType:@"image/png" fileName:[NSString stringWithFormat:@"Foto%u.png",imgNumber++]];
                                                       [mailPicker addAttachmentData:myData mimeType:@"image/jpg" fileName:[NSString stringWithFormat:@"Foto%u.jpg",imgNumber++]];

                                                   });
                          });
    // il faut dismisser le controleur, sinon les contrôles ne se réaffichent pas correctement pour la prochaine photo
    [self dismissViewControllerAnimated:YES completion: ^{ [self photo:self]; } ];
    
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
    [[self message] setText:@"Préparation du mail..."];
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
    
    //on attend que toutes les images ait été ajoutées avant d'afficher
    dispatch_group_notify(imgGroup, dispatch_get_main_queue(),
                          ^{
                              // quand tout est prêt on affiche le mail
                              NSLog(@"présente mail controller %@", [NSDate date]);
                              [self presentViewController:mailPicker animated:YES completion:nil];
                          }
                          );
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
            [[self message] setText:@"mail non envoyé"];
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Result: saved");
            break;
        case MFMailComposeResultSent:
            [[self message] setText:@"mail envoyé"];
            NSLog(@"Result: sent");
            break;
        case MFMailComposeResultFailed:
            [[self message] setText:@"mail non envoyé"];
            NSLog(@"Result: failed");
            break;
        default:
            [[self message] setText:@"mail non envoyé"];
            NSLog(@"Result: not sent");
            break;
    }

    [self.activityIndicator stopAnimating];
//    images = [[NSMutableArray alloc] init]; //on réinitialise le tableau d'images
    [self preparePhoto];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
