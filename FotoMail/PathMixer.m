//
//  PathMixer.m
//  FotoMail
//
//  Created by Alistef on 07/08/2017.
//  Copyright © 2017 garfromDev. All rights reserved.
//

#import "PathMixer.h"



@implementation PathMixer

/**
 draw the path onto the originaleImage and call completion
 with the result as new UIImage
 In case of invalid image, completion is not called
 */
+ (void) saveEditedWithImage: (UIImage *)originaleImg paths: (NSArray<OverPath *> *)paths completion:(void(^)(UIImage *finalImg)) completion{
    
    // situation de départ , on a
    // - image originelle
    // - les paths
    
    // 1 créer une image à fond noir
    NSLog(@"1 créer une image à fond noir");
    if( originaleImg==nil || !(originaleImg.size.width > 0 && originaleImg.size.height > 0)){
        NSLog( @"originale image est vide!");
        return; //invalid image, completion not called
    }
    UIGraphicsBeginImageContextWithOptions(originaleImg.size, YES, originaleImg.scale);
    CGContextRef pathContext = UIGraphicsGetCurrentContext();
//    NSAssert(self.bounds.size.width == originaleImg.size.width, @"self.bounds n'est pas égale à originale image");
    CGRect rect = CGRectMake(0, 0, originaleImg.size.width, originaleImg.size.height);
    UIBezierPath *r = [UIBezierPath bezierPathWithRect:rect]; //est-on sur que ce soit la même taille que originale image?
    [UIColor.blackColor set];
    [r stroke];
    [r fill];
    
    //modification du système de coordonnées entre UIKit et CoreGraphic
    CGContextTranslateCTM(pathContext, 0.0, originaleImg.size.height);
    CGContextScaleCTM(pathContext, 1.0, -1.0);
    
    // 2 dessiner les path dans une image pathImage en couleur blanche, gomme en noire
    for( OverPath *p in paths){
        NSLog(@"drawing path into mask with rubber %@", p.rubber ? @"ON" : @"OFF");
        if(!p.rubber){
            [UIColor.whiteColor set];
        }else{
            [UIColor.blackColor set];
        }
        [p.path stroke];
    }
    
    CGImageRef pathImage = CGBitmapContextCreateImage(pathContext);
    NSAssert(pathImage != nil, @"création path image a échouée");
    
    // 3 créer un image masque profondeur 1 bit depuis cette image
    // BitsPerComponent = 1 does not work, must be same as pathImage
    NSLog(@"creating mask");
    CGImageRef msq = CGImageMaskCreate( originaleImg.size.width,
                                       originaleImg.size.height,
                                       CGImageGetBitsPerComponent(pathImage),
                                       CGImageGetBitsPerPixel(pathImage),
                                       CGImageGetBytesPerRow(pathImage),
                                       CGImageGetDataProvider(pathImage),
                                       nil,
                                       FALSE);
    
    UIGraphicsEndImageContext();
    CGImageRelease(pathImage);
    
    // 4 dessiner les path rubber-off (en respectant leurs couleurs) dans l'image finale
    UIGraphicsBeginImageContextWithOptions(originaleImg.size, YES, originaleImg.scale);
    CGContextRef finalContext = UIGraphicsGetCurrentContext();
    for( OverPath *p in paths){
        NSLog(@"drawing path with rubber %@", p.rubber ? @"ON" : @"OFF");
        if(!p.rubber){
            [p.drawColor set];
            [p.path stroke];
        }
    }
    // 5 appliquer clipToMask
    // il faut des valeurs de 1 (blanc) là où l'image originelle doit apparaitre
    // il faut des valeurs de 0 (noir) là ou les path doivent apparaitres
    // !!! les path sont à moitié transparents -> à corriger
    NSLog(@"5 appliquer clipToMask");
    CGContextClipToMask(finalContext,
                        CGRectMake(0, 0,
                                   originaleImg.size.width, originaleImg.size.height),
                        msq);
    
    
    // 6 dessiner le fond (image originelle)
    NSLog(@"// 6 dessiner le fond (image originelle)");
    UIGraphicsPushContext(finalContext);
    [originaleImg drawAtPoint:CGPointZero];
    UIGraphicsPopContext();
    CGImageRelease(msq);
    
    NSLog(@"getting composite image...");
    UIImage *finalImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    //TODO: est-ce nécessairement sur la mainQueue? si l'appel à save est fait en dispatch, faut-il refaire un dispatch?
    dispatch_async(dispatch_get_main_queue(), ^{
        completion(finalImg);
    });
}
@end
