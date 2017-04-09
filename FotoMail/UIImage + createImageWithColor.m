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

@end
