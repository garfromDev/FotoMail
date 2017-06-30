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


@class DisplayEditingView;
@class PseudoImageView; // on ne peut pas importer FotoMail-Swift.h dans un .h, seulement dans .m, voir https://stackoverflow.com/questions/26328034/importing-project-swift-h-into-a-objective-c-class-file-not-found

@interface ViewController : UIViewController <UINavigationControllerDelegate,  MFMailComposeViewControllerDelegate>
// écran de fond
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UILabel *message;

// écran appareil photo
@property (weak, nonatomic) IBOutlet UIButton *macroMode;
@property (weak, nonatomic) IBOutlet UIButton *flashMode;
@property (weak,nonatomic) IBOutlet UITextField *titre;
@property (weak,nonatomic) IBOutlet UILabel *noPhoto;
@property (weak, nonatomic) IBOutlet UISegmentedControl *flashControls;
@property (weak, nonatomic) IBOutlet UIView *cameraView;
@property (weak, nonatomic) IBOutlet UIButton *mailButton;
@property (weak, nonatomic) IBOutlet UIView *blackViewForVisualEffect;


// attention, valueChanged n'est pas appellée par UItextField quand modif programatique
- (IBAction)titleHasChanged:(UITextField *)sender;
- (IBAction) changeFlashMode:(id)sender;
- (IBAction) choisiFlashMode:(id)sender;
- (IBAction) takePicture:(id)sender;
- (IBAction) envoiMail:(id)sender;
- (IBAction) reglages:(id)sender;
- (IBAction)tapOutsideTextField:(UITapGestureRecognizer *)sender;
- (IBAction)takeAndPreview:(id)sender;


// écran preview
    @property ( nonatomic) IBOutlet UIView *previewView;
/// la scrollview
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
/// l'image originelle en fond
@property (weak, nonatomic) IBOutlet UIImageView *backView;
/// l'image transparente avec les paths surimprimé dans la scroll View, c'est elle qui génère les chemins
@property (weak, nonatomic) IBOutlet EditingImageView *imageView;



// l'image qui s'affiche pendant l'édition (sous partie de l'image totale)
@property (weak, nonatomic) IBOutlet DisplayEditingView *displayEditingView;
/// l'image de fond pendent l'édition
@property (weak, nonatomic) IBOutlet PseudoImageView *backgroundPseudoImageView;
/// le regroupement des vues affichant la petite image pendant l'édition
@property (weak, nonatomic) IBOutlet UIView *smallDrawingViews;



//les contraintes de imageView à l'intérieur de la scrollView
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageViewBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageViewTrailingConstraint;

//inutilisée
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *drawingViewBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *drawingViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *drawingViewLeadingContraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *drawingViewTopConstraint;


@property (weak, nonatomic) IBOutlet UITextField *previewTitreTextField;
@property (weak, nonatomic) IBOutlet UIToolbar *previewToolbar;
@property (weak, nonatomic) IBOutlet UIButton *rubberButton;
@property (weak, nonatomic) IBOutlet UIStackView *previewStackView;



@end

