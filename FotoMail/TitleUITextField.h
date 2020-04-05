//
//  TitreUITextField.h
//  FotoMail
//
//  Created by Alistef on 14/08/2016.
//  Copyright © 2016 garfromDev. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol ModelIndexed;

/// UITextField with only 24 characters valid in filenames allowed
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Weverything"
@interface TitleUITextField : UITextField<UITextFieldDelegate, ModelIndexed>
#pragma clang diagnostic pop
@property(nonatomic) NSString *textForEdition;
@property int modelIndex;

@end
