//
//  TitleTextFieldDelegate.h
//  FotoMail
//
//  Created by Alistef on 27/07/2016.
//  Copyright © 2016 garfromDev. All rights reserved.
//

#import <UIKit/UIKit.h>

/// ne sont admis que les caractères alphabétiques, formant un nom de fichier valide,  taille maxi 24 caractères
@interface TitleTextFieldDelegate : NSObject  <UITextFieldDelegate>
- (BOOL) textFieldShouldReturn:(UITextField *)textField;
- (BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;
@end
