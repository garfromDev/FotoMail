//
//  FotoMailUITests.m
//  FotoMailUITests
//
//  Created by Alistef on 03/07/2016.
//  Copyright © 2016 garfromDev. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "FotomailUserDefault.h"


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
    [ app launch];
    [FotomailUserDefault.defaults setImgNumber:0];
    
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
    /* : on n'a pas accès au modèle de l'application, donc on ne peut pas manipuler le compteur incrémental, qui va changer à chaque test
     On ne sait pas quel est le titre en cours et le n° en cours*/
    
    /* vérifie que
     - le n° d'image affiché après une photo ait changé
     - le titre affiché après une photo ait changé
     */
    
    
    //on attend que le bouton "take picture apparaisse
    XCUIElement *buttonTakePicture = app.buttons[@"takePicture"];
    
    [buttonTakePicture waitForExpectationWithPredicate:@"exists == true" inTestCase:self];
    //        NSLog(@"%@",[app debugDescription]);
    
    XCUIElement *noPhotoLabel = app.staticTexts[@"NoPhoto"];
    NSString *displayedBefore = noPhotoLabel.label;
    NSLog(@"--- displayed before %@", displayedBefore);
    
    XCUIElement *buttonMail = app.buttons[@"Mail"]; //pas trouvé comment vérifier l'activation du bouton mail, car exist et enabled sont toujours vrai
    //[buttonMail waitForExpectationWithPredicate:@"exists == true" inTestCase:self];
    NSLog(@"buttonMail.enabled %@", buttonMail.enabled? @"YES" : @"NO");
    XCUIElement *textField = app.textFields[@"Titre"];
    NSString *titleBefore = textField.value;
    NSLog(@"textfield.exists %@  value %@   imgNumber : %u", textField.exists? @"YES" : @"NO", textField.value, FotomailUserDefault.defaults.imgNumber);
    
    //on prend une photo
    [buttonTakePicture tap];
    
    //On vérifie que le n° d'image affiché après soit différent
    NSLog(@"noPhoto : %@", noPhotoLabel.label);
    XCTAssertFalse([noPhotoLabel.label isEqualToString:displayedBefore],@"NoPhoto must display new number after taking picture");
    
    //On vérifie que le titre affiché après soit différent
    NSLog(@"textfield.exists %@  value %@", textField.exists? @"YES" : @"NO", textField.value);
    XCTAssertFalse([textField.value isEqualToString:titleBefore],@"Titre must display new number after taking picture");
    
}

-(void)testChainingThroughPictureTakingreviewProcess{

    [XCUIDevice sharedDevice].orientation = UIDeviceOrientationPortrait;
    
    XCUIApplication *app = [[XCUIApplication alloc] init];
    
    //prend une photo avec prévisualisation
    [app.buttons[@"takeAndPreview"] tap];
    
    //fait zoomer la scrollView, dessine, swipe...
    XCUIElement *scrollView = [[[[[[app.otherElements containingType:XCUIElementTypeActivityIndicator identifier:@"Progress halted"] childrenMatchingType:XCUIElementTypeOther] elementBoundByIndex:2] childrenMatchingType:XCUIElementTypeOther] elementBoundByIndex:2] childrenMatchingType:XCUIElementTypeScrollView].element;
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
    XCUIElement *effacerLeBrouillonButton = app.sheets.collectionViews.buttons[@"Effacer le brouillon"];
    [effacerLeBrouillonButton tap];

    
}
@end

