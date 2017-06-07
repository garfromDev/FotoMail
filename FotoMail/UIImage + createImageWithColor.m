//
//  UIImage + createImageWithColor.m
//  FotoMail
//
//  Created by Alistef on 11/03/2017.
//  Copyright © 2017 garfromDev. All rights reserved.
//

#import "UIImage + createImageWithColor.h"

@implementation UIImage(createImageWithColor)

+(UIImage *)createImageWithColor: (UIColor *)color size: (CGSize) imgSize
{
    UIGraphicsBeginImageContextWithOptions(imgSize, YES, 0);
    [color setFill];
    UIRectFill(CGRectMake(0, 0, imgSize.width, imgSize.height));
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}


+(UIImage *)createImageWithGradient: (UIColor *)color1 color2: (UIColor *)color2 size: (CGSize) imgSize
{
    
    
    CAGradientLayer *layer = [CAGradientLayer layer];
    layer.frame = CGRectMake(0, 0, imgSize.width, imgSize.height);
    layer.colors = @[(__bridge id)color1.CGColor,   // start color
                     (__bridge id)color2.CGColor]; // end color
    
    UIGraphicsBeginImageContext(imgSize);
    [layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}


+(UIImage *)createTransparentImageWithSize:   (CGSize) imgSize
{
    UIGraphicsBeginImageContextWithOptions(imgSize, NO, 0);
    [UIColor.clearColor setFill];
    UIRectFill(CGRectMake(0, 0, imgSize.width, imgSize.height));
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end
