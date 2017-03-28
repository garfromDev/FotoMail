//
//  ViewController.m
//  FotoMail
//
//  Created by Alistef on 03/07/2016.
//  Copyright © 2016 garfromDev. All rights reserved.

/* NOTES
 iOS 9 minimum exigé car utilise UIStackView et ContactsUI

 
 beta test
 0.5 build 2 : added PhotoLibraryUsageDescription in info.plist to fix iTunesConnect issue
 0.5 build 3 : détection dispo torche déplacée de viewDidLoad vers changeFlasMode car camera non intialisée dans viewDidLoad
                ajout du lien vers AppStore pour la revue
 0.5 build 4 : mis à faux la clef ITSAppUsesNonExemptEncryption car blocage de ITunesConnect
 0.6 build 1 : ajout d'un mode simulateur pour réaliser les screenshots appStore
 0.7 build 1 : passé l'app en universal, ajouté vérification disonibilité mode macro, ajouté revue appStore, passé tout en anglais
 1.0 build 2 : pour release AppStore
 
 SORTIE APPSTORE
 ajouter localization textes
 ajouter contact editeur
 ajouter aide avec surimpression légendes sur image
 Ajouter message explicatif tri automatique dans gmail
*/

// NICETOHAVE : ajouter un encadré jaune quand on fait le focus à un endroit?
// NICETOHAVE : réglage puissance torche en macro avec un slider
// NICETOHAVE : réglage correction lumière comme photo système
// NICETOHAVE : undo incrémental (avoir un tableau d'image originales, on redescend à chaque shake,
//              on ajoute à la fin du tableau à chaque editingBegin
// NICETOHAVE : mode zoom numérique en macro
// NICETOHAVE : voir possibilité ajouter réglage vitesse, diaph pour améliorer stabilité macro (mode pied, mode main levé)
// NICETOHAVE : voir possibilité HDR

#import "ViewController.h"
#import "UIImage+timeStamp.h"
#import "FotoMail-Bridging-Header.h"
#import "defines.h"
#import <AVFoundation/AVFoundation.h>
#import "FotoMail-Swift.h"
#import "FotomailUserDefault.h"
#import "AVCaptureDevice+Extension.h"
#import "UIImage + createImageWithColor.h"


@interface ViewController ()
// les controles de l'appareil photo en overlay sur le UIImagePicker
    @property (nonatomic) IBOutlet UIView *overlayView;
// L'écran d'affichage de l'appareil photo
    @property (weak, nonatomic) IBOutlet UIView *cameraPreviewView;

@end

/*
cycle de prise de vue
 viewDidLoad -> preparePhoto (initialisation de la boucle)
 viewDidAppear -> photo: affiche l'appareil
 bouton simple ->TakePicture -> captureImage
 -> didFinishPickingMedia -> rend visible preview
 viewDidAppear -> ne fait rien
 preview -> utilisePhoto: ou imagePickerControllerDidCancel (appellé par bouton "retake")
    imagePickerControllerDidCancel -> photo: affiche l'appareil
    utilisePhoto mode preview : (masque preview) joint l'image au mail -> photo: affiche l'appareil
                 mode direct : joint l'image au mail
 
 icone mail -> envoiMail: dismiss le Picker et affiche le mail composer
 envoiMail -> displayComposerSheet
 Mail didFinishWithResult : dismiss le Mail composer, -> preparePhoto (nouveau cycle)
*/
@implementation ViewController 
{
    /// l'adresse e-mail de destination
    NSString *toName;
    /// le sujet par défaut du mail
    NSString *subject;

    // le controlleur de photo
    UIImagePickerController *picker;
    
    // le controleur de réglage
    IBOutlet SettingsViewController *settingsVC;
    
    // indique que l'écran de prévisualisation doit être affiché par viewDidAppear
    BOOL showPreview;
    
    /* utilisé pour garantir  que le controlleur de mail est prêt avant d'attacher les images
     / que toute les images ont été converties et attachées avant d'affichée le  composeur de mail
    */
    dispatch_group_t mailGroup, imgGroup;
    /// le controlleur de mail
    MFMailComposeViewController *mailPicker;

    /// le device de prise d'image
    AVCaptureDevice *camera;
    
    /// indique que l'écran de prévisualisation devra être affiché
    BOOL preview;

}


- (void)viewDidLoad {
    LOG
    [super viewDidLoad];
    
    subject = @"FotoMail";
    imgGroup = dispatch_group_create();
    mailGroup = dispatch_group_create();
    //note : dispatch_group_create() peut retourner null, mais que faire dans ce cas? rien cf doc apple
    
    // permettra d'adapter l'interface au nombre de photo prise et au changement du titre via observeValueForKeyPath:
    [FotomailUserDefault.defaults addObserver:self forKeyPath:@"nbImages" options:NSKeyValueObservingOptionNew context:nil];
    [FotomailUserDefault.defaults addObserver:self forKeyPath:@"titreImg" options:NSKeyValueObservingOptionNew context:nil];
    // permet d'adapter l'interface au changement de mode macro
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(macroModeHasChanged:) name:kcameraControlsMacroModeChangedNotification object:camera];
    //permet d'être averti en cas de changement des autorisations dans privacy setting
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidBecomeActiveNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        [self checkAuthorisation];
    }];
     /*
     Load the overlay view from the OverlayView nib file. Self is the File's Owner for the nib file, so the overlayView outlet is set to the main view in the nib. Pass that view to the image picker controller to use as its overlay view
     */
    [[NSBundle mainBundle] loadNibNamed:@"Overlay" owner:self options:nil];
    self.overlayView.frame = self.view.bounds;
    [self.view addSubview:self.overlayView];
    
    // charge l'écran de prévisualisation / edition et le met en subview de l'écran de prise photo
    [[NSBundle mainBundle] loadNibNamed:@"Preview" owner:self options:nil];
    self.previewView.frame = self.view.bounds;
    // configure the scrollView to avoid scrolling when drawing
    [self.scrollView configureFor2FingersScroll];
    [self.view addSubview:self.previewView];
    self.imageView.delegate = self;
    
    //on s'abonne aux notification des champs de texte pour mettre à jour l'affichage quand le titre a été édité
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(titleDidEditing:) name:UITextFieldTextDidEndEditingNotification  object:self.titre];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(titleDidEditing:) name:UITextFieldTextDidEndEditingNotification  object:self.previewTitreTextField];
    
    // on masque les commandes de flash et de macro si il n'est pas disponible
#ifndef SCREENSHOTMODE
    //reste affiché pour screenshot
    self.flashMode.hidden = ![ UIImagePickerController isFlashAvailableForCameraDevice:UIImagePickerControllerCameraDeviceRear];
#endif
    
    // démarage du 1er cycle
    [self preparePhoto];

}


// on met en place un abonnement aux changement d'orientations pour gérer la taille écran en scrollView
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    LOG
    if(!camera){return;}
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(adaptToScreenSize)    name:UIDeviceOrientationDidChangeNotification  object:nil];
}

//et on supprime l'abonnement
-(void) viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    LOG
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification  object:nil ];
}



#pragma mark Interface utilisateur prise de vue
/// masque et révèle alternativement les contrôle des flash
- (IBAction) changeFlashMode:(id)sender
{
    LOG
#ifndef SCREENSHOTMODE
    //on masque la commande de torche si la torche n'est pas disponible
    [self.flashControls setEnabled:[camera hasTorch] forSegmentAtIndex:2];
#endif
    self.flashControls.hidden = !self.flashControls.hidden;
}


/// l'utilisateur a choisi une des icones de flash mode (segmentedCOntrol)
- (IBAction) choisiFlashMode:(UISegmentedControl *)sender{

    self.flashControls.hidden = true;
    
    // 0 = FLash OFF, 1 = Flash Auto, 2 = Torche
    switch (sender.selectedSegmentIndex) {
        case 0:
            [camera setFlashOff];
            [self.flashMode setImage:[UIImage imageNamed:@"flashOff"] forState:UIControlStateNormal];
            break;
            
        case 1:
            [camera setFlashAuto];
            [self.flashMode setImage:[UIImage imageNamed:@"flashAuto"] forState:UIControlStateNormal];
            break;
        
        case 2:
            [camera setTorchOn];
            [self.flashMode setImage:[UIImage imageNamed:@"torche"] forState:UIControlStateNormal];
            break;
            
        default:
            break;
    }

}

/// règle l'appareil en macro (position 0)
/// il en ressortira dès qu'on appui sur le fond pour provoquer un focus
/// ou par appui à nouveau sur le bouton
- (IBAction) macroMode:(UIButton*)sender{
    LOG
    if([camera isMacroOn]){
        [camera setMacroOff];
    }else{
        [camera setMacroOn];
    }
}


/// l'utilisateur a touché l'icone réglages
- (IBAction) reglages:(id)sender{
    SettingsViewController *settingsViewC = [[UIStoryboard storyboardWithName:@"Settings" bundle:nil] instantiateViewControllerWithIdentifier:@"Settings"];
    [self presentViewController:settingsViewC animated:true completion:nil];
}


/// sort du mode edition si le text field est en edition, sinon provoque le focus
- (IBAction)tapOutsideTextField:(UITapGestureRecognizer *)sender {
    LOG
    if( self.titre.isFirstResponder){
        [self.titre resignFirstResponder];
    }else{
        NSLog(@"focusing");
        CGPoint pointInPreview = [sender locationInView:sender.view];
        [camera setFocusToPoint:pointInPreview];
    }
}

// on affiche le bouton macro en jaune lorque le mode macro est activé
-(void) macroModeHasChanged: (NSNotification *)notification{
    NSString *titre = camera.isMacroOn ? @"macro-jaune" : @"macro" ;
    UIImage *newImg = [UIImage imageNamed:titre];
    [self.macroMode setImage:newImg forState:UIControlStateNormal];
}


/// adapte l'interface en fonction du nombre de photo prise, pas de bouton Mail si 0 images
- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    LOG
    if ([keyPath isEqualToString:@"nbImages"]) {
        // on rend visible le bouton mail si une image au moin ets prise
        self.mailButton.hidden = (FotomailUserDefault.defaults.nbImages == 0);
        
        //on modifie le n° affiché
        NSString *nb = [NSString stringWithFormat:@"#%lu", (long) FotomailUserDefault.defaults.nbImages+1 ];
        [self.noPhoto setText:nb ];
        
        //on remet à jour le nom de l'image affiché dans titre
        [self updateTitles];
        
    }else if([keyPath isEqualToString:@"titreImg"]) {
        //on remet à jour le nom de l'image affiché dans titre
        [self updateTitles];
    }
    else{
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

//--------------------------------------
#pragma mark Picture_Taking_part
/* première étape du cycle de prise de vue
 on réinitialise les variables, l'interface et on prépare le controleur de mail neuf
 l'appareil photo sera affiché par le viewDidAppear
 */
- (void)preparePhoto
{ LOG

    // on masque les commandes de preview
    self.previewView.hidden = true;
    
    //on réinitialise le titre
    [FotomailUserDefault.defaults resetImageAndTitle];
    
    // on fait la préparation du controleur de mail en tache de fond pour afficher le plus vite possible l'appareil photo
    // on utilise le groupe mailGroup pour ne pas lancer d'attachement d'image avant que le controlleur ne soit crée
    dispatch_group_async(mailGroup, dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0),
    ^{ //on prépare le composeur de mail
        NSLog(@"allocate Mail controller %@", [NSDate date]);
        mailPicker = [[MFMailComposeViewController alloc] init];
        mailPicker.mailComposeDelegate = self;
        [mailPicker setSubject:subject];
    } );
    
    //on vérifie les autorisations, le callback est rappellé sur la mainqueue
    [self checkAuthorisation];
}


-(void) viewDidAppear:(BOOL)animated {
    LOG
    [super viewDidAppear:animated];

    // on vérifie si on est en train de préparer le mail ou d'afficher le preview, sinon on affiche l'interface de prise de photo
    if(![[self activityIndicator] isAnimating] && !showPreview) {
        [self photo:self];
    };
    showPreview = false;
}


// afiche l'interface de prise de vue (est appellée de ViewDidAppear)
// on arrive soit de prepare photo, soit de preview
- (void)photo:(id)sender {
    LOG
    self.titre.text = FotomailUserDefault.defaults.titreImg;
    self.titre.placeholder = FotomailUserDefault.defaults.nomImg;
    [[self message] setText:@""];
    self.flashControls.hidden = true;
}


// l'utilisateur appui sur le bouton de prise de photo
- (IBAction) takePicture:(id)sender{

    preview = false;
    [self visualCaptureImage:sender];
}


// l'utilisateur appui sur le bouton de prise de photo + preview
- (IBAction)takeAndPreview:(id)sender {
#ifndef SCREENSHOTMODE
        preview = true;
        [self visualCaptureImage:sender];
#endif
#ifdef SCREENSHOTMODE
        //on affiche directement l'interface de preview en mode screenshot
        self.previewView.hidden = false;
#endif

}

/// gère les effets et le son de la capture de l'image
- (void) visualCaptureImage: (id)sender {
    //pour éviter les problème de rebond, on désactive le bouton
    // et on le réactive une fois l'image capturée
    UIButton *button = (UIButton *)sender;
    button.enabled = false;
    
    // on provoque l'effet d'obturateur et on capture l'image
    [self.blackViewForVisualEffect darkBlink];
    // ceci est effectué immédiatement pour être synchro avec l'éventuel effet visuel
    if (NSFoundationVersionNumber >= NSFoundationVersionNumber_iOS_9_0){
        AudioServicesPlaySystemSoundWithCompletion(PHOTO_SOUND, nil);
    } else {
        AudioServicesPlaySystemSound(PHOTO_SOUND);
    }
#ifndef SCREENSHOTMODE
    [self captureImage: ^{ button.enabled = true;}  ];
    //appellera Picker didFinishPickingMediaWithInfo,
#else
    //on reaffiche le bouton et on appelle directement didFinishPickingMediaWithInfo
    // avec une image factice
    button.enabled = true;
    UIImage *greenImg = [UIImage createImageWithColor:[UIColor greenColor] size:CGSizeMake(DUMMYWIDTH, DUMMYHEIGHT)];
    [self imagePickerController:nil didFinishPickingMediaWithInfo:@{ UIImagePickerControllerOriginalImage:greenImg}];
#endif
    
}



/// capture l'image puis appelle le bloc completion sur la main queue et appelle Picker didFinishPickingMediaWithInfo
-(void) captureImage: (dispatch_block_t )completion {
    // voir https://www.objc.io/issues/21-camera-and-photos/camera-capture-on-ios/
    // dans un 2eme temps, peutêtre un objet simili picker aurait un interet pour sortir du code du controller?
    LOG
    
    [camera captureUIImage:^(UIImage *stillImg){
                //bloc exécuté à la fin de l'acquisition
                //On rajoute le timeStamp si demandé
                if ([[FotomailUserDefault defaults] timeStamp]) {
                    float size = [[ FotomailUserDefault defaults] stampSize];
                    stillImg = [stillImg addTimeStampWithFontSize:size];
                }
                //on appelle completion sur la mainQueue et on rend la main via didFinishPickingMediaWithInfo
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSLog(@"takePicture - calling didFinishPicking");
                    completion();
                    [self imagePickerController:nil didFinishPickingMediaWithInfo:@{UIImagePickerControllerOriginalImage:stillImg}];
                });
            }
     ];
}


//--------------------------------------
#pragma mark  Photo_Picker_Delegate
/** Une image a été choisie, on l'ajoute en pièce jointe au mail, on dismiss l'appareil photo pour le rafficher aussitot. Pour raison de récupération code existant, signature du pickerDelegate
    l'image prise est passée sous la clef UIImagePickerControllerOriginalImage du dico
*/
- (void)imagePickerController:(nullable UIImagePickerController *) Picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{

    UIImage *img = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    // on met l'image dans imageView quel que soit le mode car utilisePhoto récupère l'image dans imageView
    [self.scrollView setZoomScale:1.0];
    [self.imageView setFrame:CGRectMake(0, 0, img.size.width, img.size.height)];
    self.imageView.image = img;

    // affiche le controleur de Preview si option activée
    if(preview){
        
        [FotomailUserDefault.defaults prepareUndo];
        
        //on cache l'appareil photo
        showPreview = true;

        //on anime l'animation de la preview
            [self.previewView slideFromBottomWithBouncing:true duration:0.5 completion:^(BOOL finished) {
                //on règle le niveau de zoom pour afficher l'image en entier
                [self updateMinZoomScaleForSize:self.previewView.frame.size];
                [self scrollViewDidZoom:self.scrollView];
            }];

    }else{
        //option non activé, on joint directement la photo au mail et on laisse l'appareil photo affiché
        [self utilisePhoto:nil ];
     }
}


// l'utilisateur a cliqué sur la croix rouge dans preview, on ne compte pas l'image et on cache l'écran de prévisualisation, on remet l'ancien titre
- (IBAction)imagePickerControllerDidCancel
{   // l'utilisateur a annulé la prise de photo, on masque l'aperçu et on réaffiche l'appareil photo
    NSLog(@"cancel appuyé dans imagePicker");
    [FotomailUserDefault.defaults commitUndo]; //restaure le titre avant preview
    self.previewView.hidden = true;
    showPreview = false;
    [self photo:self];
}


#pragma mark gestion titre
- (void)updateTitles
{
    LOG
    // met à jour les placeholder des 2 champs overlay et preview
    self.titre.placeholder = [FotomailUserDefault.defaults nomImg];
    self.previewTitreTextField.placeholder = FotomailUserDefault.defaults.nomImg;
    
    // met à jour le titre des champs texte
    [self.titre setText:FotomailUserDefault.defaults.titreImg];
    [self.previewTitreTextField setText:FotomailUserDefault.defaults.titreImg];
}

///appelé par les 2 zones de titres (Overlay et Preview)
/// met à jour le titre du modèle
/// met à jour les placeholder des 2 champs overlay et preview
/// met à jour le titre de l'autre champ
- (IBAction)titleHasChanged:(TitleUITextField *)sender
{
    LOG
    // met à jour le titre du modèle
    FotomailUserDefault.defaults.titreImg = [NSString stringWithString:sender.text];
    [self updateTitles];
    
    NSLog(@"titreImg new value : %@",FotomailUserDefault.defaults.titreImg );
}


/// appellé lorsque la notification UITextFieldTextDidEndEditingNotification est reçue
-(void) titleDidEditing:(NSNotification *)notification{
    LOG
    UITextField *field = (UITextField *)notification.object;
    [self titleHasChanged:field];
}


- (IBAction)tapOutsidePreviewTextField:(UITapGestureRecognizer *)sender {
    [self.previewTitreTextField resignFirstResponder];
}


#pragma mark Gestion Previsualisation
- (void) adaptToScreenSize{

    if(!self.previewView.hidden){
        [self scrollViewDidZoom:self.scrollView];
    }
}


#pragma mark suite picture tacking part
/* l'utilisateur a confirmé l'utilisation de l'image éventuellement éditée lors de la preview 
 Note : le nom de l'image est attribué lors de son attachement au controleur de mail
 si l'utilisateur annule le mail, la photo suivante recevra un nouveau nom avec le n° incrémenté*/
- (IBAction)utilisePhoto:(id)sender
{
    LOG
    // on masque l'écran de preview
    if(!self.previewView.hidden){
        showPreview = false;
        [self.previewView slideToBottomWithDuration:0.2 completion:^(BOOL finished){}];
    }

    // on récupère l'image éventuellement éditée dans l'UIImageView
    __block  UIImage *imgDef = self.imageView.image;
    __block NSString *fileName = [FotomailUserDefault.defaults nomImg];
    [FotomailUserDefault.defaults nextName];
    FotomailUserDefault.defaults.nbImages++; //doit être fait après le nextName sinon le nom modifié n'ets pas réaffiché par l'observation de nbImage
    [[self message] setText:@"saving image..."]; //"sauvegarde de l'image"
    // on effectue en tache de fond la transformation et l'attachement de l'image
    // le imgGroup permet d'attendre la fin de tous les attachements avant d'afficher le mail composer
    dispatch_group_async(imgGroup, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0),
                         ^{
                             NSLog(@"conversion asynchrone image %lu - %@",(unsigned long)FotomailUserDefault.defaults.nbImages, [NSDate date]);
                             NSData * myData = UIImageJPEGRepresentation(imgDef, 1.0);
                             NSLog(@"conversion image finie %lu - %@",(unsigned long)FotomailUserDefault.defaults.nbImages,[NSDate date]);
                             
                             dispatch_group_notify(mailGroup, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0),
                                    ^{
                                        NSLog(@"attachement de l'image %@", fileName);
                                        [mailPicker addAttachmentData:myData mimeType:@"image/jpg" fileName:fileName];
                                    });
                         });
    if(preview) { // on le réaffiche
        [self photo:self];
    }
}


//--------------------------------------
#pragma mark e-mail sending part

/* l'utilisateur a cliqué sur "envoi mail"
 on masque le controleur de photo et on affiche le controleur de mail
 */
- (IBAction) envoiMail:(id)sender{
    LOG
    if(FotomailUserDefault.defaults.nbImages == 0){ //normalement ne sera pas appellé puisque l'état visible du bouton est géré
        return;
    }
    [[self message] setText:@"Preparing mail..."]; //@"Préparation du mail..."
    [self.activityIndicator startAnimating];
    [self displayComposerSheet];
}


-(void)displayComposerSheet
{
    if (![MFMailComposeViewController canSendMail]) {
        NSLog(@"Mail services are not available.");
        self.message.text = @"Mail services are not available"; //@"Fonction d'envoi de mail non disponible";
        return;
    }
    
    // on met à jour la liste de destinataire qui a pu changer entre temps (réglages)
    [mailPicker setToRecipients:[FotomailUserDefault.defaults recipients]];
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
            [[self message] setText:@"mail not sent"]; //@"mail non envoyé"
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Result: saved");
            break;
        case MFMailComposeResultSent:
            [[self message] setText:@"mail succesfully sent"]; //@"mail envoyé"
            [[Reviewmanager sharedInstance] userHasAchieved];
            [[Reviewmanager sharedInstance] checkReview];
            NSLog(@"Result: sent");
            break;
        case MFMailComposeResultFailed:
            [[self message] setText:@"mail not sent"]; //@"mail non envoyé"
            NSLog(@"Result: failed");
            break;
        default:
            [[self message] setText:@"mail not sent"]; //@"mail non envoyé"
            NSLog(@"Result: not sent");
            break;
    }

    [self.activityIndicator stopAnimating];
    // on lance un nouveau cycle
    [self preparePhoto];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark la partie UIScrollViewDelegate est dans le fichier extensionViewController

#pragma mark gestion du shake
- (BOOL)canBecomeFirstResponder {
    return YES;
}


- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    if (motion == UIEventSubtypeMotionShake) {
        NSLog(@"shake");
        if(!self.previewView.hidden){
            EditingImageView *editor = (EditingImageView *)self.imageView;
            [editor undoEditing];
        }
        
    }
}



#pragma mark Personalisation de l'aspect
/// On masque la barre d'état
- (BOOL) prefersStatusBarHidden {
    return true;
}



#pragma mark Gestion de la rotation
-(void)viewDidLayoutSubviews{
    LOG
    [super viewDidLayoutSubviews];
    if(!camera) {return;} //rien à faire si pas de caméra initialisée ou accessible
    // Merci à Matteo Caldari, c'est le truc qui manquait pour faire fonctionner la rotation
    camera.cameraLayer.frame = self.cameraPreviewView.bounds;
    camera.cameraLayer.connection.videoOrientation = [orientationHelper convertInterfaceOrientationToAVCatureVideoOrientationWithUi:[[UIApplication sharedApplication] statusBarOrientation]];
    // on remet à jour le bouton mail car en cas de rotation, un des deux n'était pas activé
    // et n'a donc pas pris le changement
    self.mailButton.hidden = (FotomailUserDefault.defaults.nbImages == 0);
    
    //on tente une remise à jour de displayEditingView pour forcer un réaffichage à l'endroit
    [self.diplayEditingView setNeedsDisplay];
}


#pragma mark gestion des autorisations d'accès à la caméra


/// vérifie les autorisation d'accès et change de mode en fonction de la réponse
/// appellé par preparePhoto au début de chaque cycle ou par notification d'activation de l'application
-(void) checkAuthorisation
{   LOG
    //on vérifie les autorisations, le callback est rappellé sur la mainqueue
    [AVCaptureDevice checkCameraAuthorizationWithCompletion:^(BOOL granted) {
#ifdef SCREENSHOTMODE
        [self setAuthorized];
#else
        if(granted){
            [self setAuthorized];
        }else{
            [self setNonAuthorized];
        }
#endif
    }];

}


/// l'accès à l'appareil photo n'est pas autorisé, passe en mode d'affichage du message
-(void)setNonAuthorized{
    LOG
    if(camera){
        //perte de l'authorization, on retire la couche de prévisualisation et on release l'objet camera
        [self.cameraView.layer.sublayers.lastObject removeFromSuperlayer];
        camera = nil;
    }
    self.overlayView.hidden = true;
    [self.message setText:@"Camera usage not authorized\nChange Fotomail privacy setting for camera in Settings"];
}


/// l'accès à l'appareil photo est autorisé, passe en mode d'affichage de l'appareil photo
-(void)setAuthorized{
    // Mise en place de l'affichage temps réel appareil photo
    LOG
    if(!camera){ //création de l'objet camera si il n'existe pas
        camera = [AVCaptureDevice initCameraOnView:self.cameraPreviewView error: nil];
    }
    if( camera == nil){ //si la création échoue, cela signifie qu'il n'y a pas de caméra disponible
#ifdef SCREENSHOTMODE
        //on affiche un fond vert pour permettre l'incrustation d'images en postproduction
        self.cameraPreviewView.backgroundColor = [UIColor greenColor];
#else
        self.message.text = @"No camera available"; //@"Appareil photo non disponible"
        return; //on arrête tout et on affiche un message si appareil photo pas disponible
#endif
    }
    self.overlayView.hidden = false;
#ifndef SCREENSHOTMODE
    //on masque les commandes macro si le device n'est pas capable
    self.macroMode.hidden = ![camera isMacroAvailable];
#endif
    NSLog(@"setAuthorized camera initialisée...");
}


@end
