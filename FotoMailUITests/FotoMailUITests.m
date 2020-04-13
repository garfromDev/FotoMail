//
//  FotoMailUITests.m
//  FotoMailUITests
//
//  Created by Alistef on 03/07/2016.
//  Copyright © 2016 garfromDev. All rights reserved.
//

#import <XCTest/XCTest.h>

#define STD_TIMEOUT 5.0

@implementation XCUIElement(waitForExpectation)

/*! attend qu'une condition soit remplie pour l'objet
 
 @param predicateFormat : une chaine avec la condition (au format NSPredicateWithFormat)
 @param inTestCase : la référence de l'instance du testCase
 @return
 @discussion Utilisation :
 @code [buttonTakePicture waitForExpectationWithPredicate:@"exists == true" inTestCase:self];
 @endcode
 */
-(void) waitForExpectationWithPredicate: (NSString *)predicateFormat inTestCase:(XCTestCase *)testCase {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateFormat];
    [testCase expectationForPredicate:predicate evaluatedWithObject:self handler:nil];
    [testCase waitForExpectationsWithTimeout:STD_TIMEOUT handler:nil];
}
@end



@interface FotoMailUITests : XCTestCase

@end

@implementation FotoMailUITests

XCUIApplication *app;

- (void)setUp {
    [super setUp];
    
    // Put setup code here. This method is called before the invocation of each test method in the class.
    NSLog(@"set up running --");
    // In UI tests it is usually best to stop immediately when a failure occurs.
    self.continueAfterFailure = YES;
    // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
    app = [[XCUIApplication alloc] init];
    /* userdefault can be set through command line, see https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/UserDefaults/AboutPreferenceDomains/AboutPreferenceDomains.html#//apple_ref/doc/uid/10000059i-CH2-SW1
       this will not be recorded in disk, only transient during app's lifetime
     */
    [app setLaunchArguments: @[@"-imgNumber", @"0"]];
    [ app launch];
    // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

// exemple de formation d'une expectation
//    NSPredicate *doesExist = [NSPredicate predicateWithFormat:@"exists == true"];
//    [self expectationForPredicate:doesExist evaluatedWithObject:buttonTakePicture handler:nil];
//    ici d'autres expectations si nécessaire...
//    [self waitForExpectationsWithTimeout:5.0 handler:nil];


- (void)testTakePictureButton {
    // Note : si un message parlant de problème de signature de l'appli appparait quand on teste sur iphone 5S
    // il faut le rebooter (probleme 32 bits) https://stackoverflow.com/questions/39464682/dtdevicekit-could-not-start-house-arrest-service-for-app-identifier-xxx
    /* : on n'a pas accès au modèle de l'application, donc on ne peut pas manipuler le compteur incrémental, qui va changer à chaque test
     On ne sait pas quel est le titre en cours et le n° en cours*/
    
    /* vérifie que
     - le n° d'image affiché après une photo ait changé
     - le titre affiché après une photo ait changé
     */

    //on attend que le bouton "take picture apparaisse
    XCUIElement *buttonTakePicture = app.buttons[@"takePicture"];
    
    [buttonTakePicture waitForExpectationWithPredicate:@"exists == true" inTestCase:self];
    // on mémorize le numero et titre actuel
    XCUIElement *noPhotoLabel = app.staticTexts[@"NoPhoto"];
    NSString *displayedBefore = noPhotoLabel.label;
    NSLog(@"--- displayed before %@", displayedBefore);
    XCUIElement *textField = app.textFields[@"Titre"];
    NSLog(@"textfield.exists %@  value %@   ", textField.exists? @"YES" : @"NO", textField.value);
    // le bouton mail ne doit pas être disponible
    XCTAssert(![app.buttons[@"Mail"] exists]);
    
    //on prend une photo
    [buttonTakePicture tap];
    
    // il faut attendre que le bouton soit de nouveau disponible
    [buttonTakePicture waitForExpectationWithPredicate:@"enabled == true" inTestCase:self];
    
    //On vérifie que le n° d'image affiché après soit différent
    NSLog(@"noPhoto : %@", noPhotoLabel.label);
    XCTAssertFalse([noPhotoLabel.label isEqualToString:displayedBefore],@"NoPhoto must display new number after taking picture");
    // vérification du titre déjà faite dans les test unitaires controlleur
    // le bouton d'envoi de mail doit avoir apparu
    XCTAssert([app.buttons[@"Mail"] exists]);
}

-(void)testChainingThroughPictureTakingreviewProcess{

    [XCUIDevice sharedDevice].orientation = UIDeviceOrientationPortrait;
    XCUIApplication *app = [[XCUIApplication alloc] init];
    
    //prend une photo avec prévisualisation
    [app.buttons[@"takeAndPreview"] tap];
    XCUIElement *buttonDone = app.toolbars.buttons[@"use"];
    [buttonDone waitForExpectationWithPredicate:@"exists == true" inTestCase:self];
    //fait zoomer la scrollView, dessine, swipe...
    XCUIElement *scrollView = [app.scrollViews firstMatch];
    [scrollView pinchWithScale:2.0 velocity:1];
    XCUIElement *image = [app.scrollViews childrenMatchingType:XCUIElementTypeImage].element;
    [image tap];
    [image pressForDuration:1];
    [image swipeLeft];
    [image swipeUp];
    [scrollView swipeLeft];
    
    //on valide l'image
    [app.toolbars.buttons[@"use"] tap];

    //on prépare le mail puis on abondonne
    [app.buttons[@"Mail"] tap];
    [app.navigationBars[@"FotoMail"].buttons[@"Annuler"] tap];
    XCUIElement *effacerLeBrouillonButton = [[[app.sheets elementBoundByIndex:0] buttons] elementBoundByIndex:0];
    [effacerLeBrouillonButton tap];
}

@end

