//
//  TitreUITextField.h
//  FotoMail
//
//  Created by Alistef on 14/08/2016.
//  Copyright © 2016 garfromDev. All rights reserved.
//

#import <UIKit/UIKit.h>
/// UITextField with only 24 characters valid in filenames allowed
@interface TitleUITextField : UITextField<UITextFieldDelegate>

@property(nonatomic) NSString *textForEdition;

@end
