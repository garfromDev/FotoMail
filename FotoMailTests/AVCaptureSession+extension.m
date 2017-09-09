//
//  AVCaptureSession+extension.m
//  FotoMail
//
//  Created by Alistef on 12/08/2017.
//  Copyright © 2017 garfromDev. All rights reserved.
//

#import "AVCaptureSession+extension.h"


/*
 Cette extension modifie le comportement de canSetSessionPreset:
 pour tester l'effet en cas d'erreur
 ------------------------------
 !!!!!!!! ATTENTION !!!!!!!!!!
 -------------------------------
 ne pas importer dans le code production, car le
 comportement de la classe AVCaptureSession peut devenir incontrolable
 
 */
@implementation AVCaptureSession(TestExtension)

-(BOOL)canSetSessionPreset:(NSString *)preset{

        return NO;    
}

@end
