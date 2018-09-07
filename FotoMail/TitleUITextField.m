//
//  TitreUITextField.m
//  FotoMail
//
//  Created by Alistef on 14/08/2016.
//  Copyright © 2016 garfromDev. All rights reserved.
//

#import "TitleUITextField.h"
#import "TitleTextFieldDelegate.h"
#import "defines.h"
#import "FotoMail-Swift.h"

@interface TitleUITextField(){
//keep living the delegate object as long as this UITextField is living
TitleTextFieldDelegate *myDelegate; //ATTENTION, je l'avais par erreur déclaré dans le @implementation, dans ce cas c'est une variable de classe et le délégué du 2ème textField releasait le délégué du 1er
}
@end

@implementation TitleUITextField


- (id)initWithCoder:(NSCoder *)aDecoder {
    NSLog(@"TitleUITextField initWithCoder");
    self = [super initWithCoder:aDecoder];
    if (self) {
        myDelegate = [[TitleTextFieldDelegate alloc] init] ;
        self.delegate = self;
    }
    return self;
}



/// on n'affiche pas le texte mais le placeHolder tant qu'on est pas en édition
-(void) setText:(NSString *)text{
    LOG
    if (self.isEditing){ return;}
    NSString *rplcmt = self.isEditing ? text : self.placeholder;
    self.textForEdition = [NSString stringWithString:text];
    [super setText:rplcmt];
    NSLog(@"textForEdition: %@  text: %@  isEditing: %@", ((TitleUITextField *)self).textForEdition, self.text, self.isEditing?@"TRUE":@"FALSE");

}

/// calls  delegate method
-(BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    LOG
    NSLog(@"textForEdition: %@  text: %@  isEditing: %@", ((TitleUITextField *)textField).textForEdition, textField.text, textField.isEditing?@"TRUE":@"FALSE");
//    return [myDelegate textField:textField shouldChangeCharactersInRange:range replacementString:string];
    BOOL ret = [myDelegate textField:textField shouldChangeCharactersInRange:range replacementString:string];
    NSLog(@"textForEdition: %@  text: %@  isEditing: %@", ((TitleUITextField *)textField).textForEdition, textField.text, textField.isEditing?@"TRUE":@"FALSE");
    return ret;
}

/// calls  delegate method
-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    LOG
    NSLog(@"textForEdition: %@  text: %@  isEditing: %@", ((TitleUITextField *)textField).textForEdition, textField.text, textField.isEditing?@"TRUE":@"FALSE");
//    return [myDelegate textFieldShouldReturn:textField];
    BOOL ret =  [myDelegate textFieldShouldReturn:textField];
    NSLog(@"textForEdition: %@  text: %@  isEditing: %@", ((TitleUITextField *)textField).textForEdition, textField.text, textField.isEditing?@"TRUE":@"FALSE");
    return ret;
}

/// when editing begins, we replace text with textForEdition that was memotized duting setText, or with empty if no textForEdition
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    LOG
    NSLog(@"textForEdition: %@  text: %@  isEditing: %@", ((TitleUITextField *)textField).textForEdition, textField.text, textField.isEditing?@"TRUE":@"FALSE");

        if(self.textForEdition != nil){
            [super setText:self.textForEdition];
        }else{
            [super setText:@""];
        }
        NSLog(@"textForEdition: %@  text: %@  isEditing: %@", ((TitleUITextField *)textField).textForEdition, textField.text, textField.isEditing?@"TRUE":@"FALSE");
        return YES;

}

/// at the end of editing, we memorize text and replace it with placeHolder
-(BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    LOG
    NSLog(@"textForEdition: %@  text: %@  isEditing: %@", ((TitleUITextField *)textField).textForEdition, textField.text, textField.isEditing?@"TRUE":@"FALSE");

        self.textForEdition = [NSString stringWithString:textField.text];
        //    [super setText:textField.placeholder];
        NSLog(@"textForEdition: %@  text: %@  isEditing: %@", ((TitleUITextField *)textField).textForEdition, textField.text, textField.isEditing?@"TRUE":@"FALSE");
        return YES;

}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    LOG
    NSLog(@"textForEdition: %@  text: %@  isEditing: %@", ((TitleUITextField *)textField).textForEdition, textField.text, textField.isEditing?@"TRUE":@"FALSE");

    self.textForEdition = [NSString stringWithString:textField.text];
    NSLog(@"textForEdition: %@  text: %@  isEditing: %@", ((TitleUITextField *)textField).textForEdition, textField.text, textField.isEditing?@"TRUE":@"FALSE");
    
}

#pragma mark- ModelIndexed protocol

int _modelIndex;

-(int)modelIndex {
    return _modelIndex;
}

-(void) setModelIndex:(int)modelIndex{
    self.tag = modelIndex;
}

@end
