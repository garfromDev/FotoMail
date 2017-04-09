//
//  TitleTextFieldDelegate.m
//  FotoMail
//
//  Created by Alistef on 27/07/2016.
//  Copyright © 2016 garfromDev. All rights reserved.
//

#import "TitleTextFieldDelegate.h"

#define TITLE_FIELD_MAX_LENGTH 24

@implementation TitleTextFieldDelegate

// ne sont admis que les caractères alphabétiques, formant un nom de fichier valide,  taille maxi 24 caractères
- (BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    NSLog(@"textField shouldChangeCharactersInRange");
    // vérification que l'on ajoute uniquement des charactères alphabétiques et underscore
    NSMutableCharacterSet *mset = [NSMutableCharacterSet characterSetWithCharactersInString:@"_"];
    [mset formUnionWithCharacterSet:[NSCharacterSet alphanumericCharacterSet]  ];
    NSCharacterSet *set = [mset invertedSet];
    
    if([string rangeOfCharacterFromSet:set].location != NSNotFound )
        { return false; }
    
    NSString *ancien=textField.text;
    NSString *nouveau = [ancien stringByReplacingCharactersInRange:range withString:string];
    
    // vérification de la taille maxi
    if( nouveau.length > TITLE_FIELD_MAX_LENGTH ){
        return false;
    }

    //vérification que le nom est un nom de fichier valide
    if ( [@"/" stringByAppendingString:nouveau].isAbsolutePath ) {
            return true;
    }
    return false;
}


- (BOOL) textFieldShouldReturn:(UITextField *)textField{
    NSLog(@"textFieldShouldReturn");
    [textField resignFirstResponder];
    return true;
}

@end
