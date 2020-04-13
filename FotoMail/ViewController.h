//
//  ViewController.h
//  FotoMail
//
//  Created by Alistef on 03/07/2016.
//  Copyright © 2016 garfromDev. All rights reserved.
/* =========================================================================================
 
 this application is intended to automatize the task of
 - taking one or many picture (including macro and torch control )
 - adding timestamp to picture
 - highligting some details
 - sending the pictures by e-mail to predefined recipients in one click
 - eventually allowing automated picture handling by e-mail application  using custom rules
 - without overloading the device or iCloud storage space with many picture stored
 
 ========================================================================================= */


#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "editingImageView.h"
#import "FotoMail-Bridging-Header.h"
#import "MailComposer Protocol.h"

@class TransparentPathView;
@class EditingSupportImageView;
@class FotoMailPathManager;
@class AutoZoomingScrollView;
@protocol AbstractCameraDevice;
@protocol CameraManager;
// on ne peut pas importer FotoMail-Swift.h dans un .h, seulement dans .m, voir https://stackoverflow.com/questions/26328034/importing-project-swift-h-into-a-objective-c-class-file-not-found

@interface ViewController : UIViewController <UINavigationControllerDelegate,  MFMailComposeViewControllerDelegate>
// écran de fond
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UILabel *message;
@property (weak, nonatomic) IBOutlet UILabel *mailAvailabilityMessage;

// écran appareil photo
@property (weak, nonatomic) IBOutlet UIButton *macroMode;
@property (weak, nonatomic) IBOutlet UIButton *flashMode;
/// le nom du fichier photo qui sera généré
@property (weak,nonatomic) IBOutlet UITextField *titre;
@property (weak,nonatomic) IBOutlet UILabel *noPhoto;
@property (weak, nonatomic) IBOutlet UISegmentedControl *flashControls;
@property (weak, nonatomic) IBOutlet UIView *cameraView;
@property (weak, nonatomic) IBOutlet UIButton *mailButton;
@property (weak, nonatomic) IBOutlet UIView *blackViewForVisualEffect;
@property (weak, nonatomic) IBOutlet UIButton *project;


// attention, valueChanged n'est pas appellée par UItextField quand modif programatique
- (IBAction)titleHasChanged:(UITextField *)sender;
- (IBAction) changeFlashMode:(id)sender;
- (IBAction) choisiFlashMode:(id)sender;
- (IBAction) takePicture:(id)sender;
- (IBAction) envoiMail:(id)sender;
- (IBAction) reglages:(id)sender;
- (IBAction)tapOutsideTextField:(UITapGestureRecognizer *)sender;
- (IBAction)takeAndPreview:(id)sender;
- (IBAction)projectLongPress:(UILongPressGestureRecognizer *)sender;


// écran preview
    @property ( nonatomic) IBOutlet UIView *previewView;
/// la scrollview
@property (weak, nonatomic) IBOutlet AutoZoomingScrollView *scrollView;
/// l'image transparente avec les paths surimprimé devant la scroll View
@property (weak, nonatomic) IBOutlet TransparentPathView *clrView;
/// l'image contenu dans la scrollView, c'est elle qui génère les path
@property (weak, nonatomic) IBOutlet EditingSupportImageView *imageView;
/// le nom du projet sélectionné
@property(weak, nonatomic) IBOutlet UILabel *previewProject;
-(IBAction)cropAccordingCurrentView:(id)sender;
/* principe de fonctionnement :
 la scrollview est configurée pour ne traiter que les touches à 2 doigts pour le pan
 La EditingSupportImageView dans la scrollview est une ImageView qui affiche l'image originale
 en même temps,traite les touch event à un doigt pour générer les paths. et les envoyer
 au PathManager. celui-ci les stockes en ajoutant les informations de couleur et de mode gomme/dessin
 Le viewController, en tant que PathProvider, fourni les paths à afficher ainsi que les infos de zoom
 et d'offset à la TransparentPathView qui est devant la scrollView avec la même taille
 */

// les menu de la preview
@property (weak, nonatomic) IBOutlet UITextField *previewTitreTextField;
@property (weak, nonatomic) IBOutlet UIToolbar *previewToolbar;
@property (weak, nonatomic) IBOutlet UIButton *rubberButton;
@property (weak, nonatomic) IBOutlet UIStackView *previewStackView;

/// le pathManager qui stocke les paths (annotations graphiques)
@property FotoMailPathManager *pathManager;

/// le device de prise d'image (we use protocol to be able to inject mock for testing)
@property  id <AbstractCameraDevice> camera;
/// le Camera Manager qui fournit l'objet camera et les autorisations
@property id <CameraManager> cameraManager;

/// the e-mail composition controller (we use protocol to be able to inject mock for testing)
@property Class mailComposerClass;

@end

