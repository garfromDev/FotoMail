//
//  UIImage + createImageWithColor.h
//  FotoMail
//
//  Created by Alistef on 11/03/2017.
//  Copyright © 2017 garfromDev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage(createImageWithColor)

/*! cretae an image with the requested size and background color
 @param color the UIColor to use to fill the image
 @param size the requested size of the image
 @return an UIImage filled with color
 @discussion no check is done against wrong size or color
 */
+(UIImage *)createImageWithColor: (UIColor *)color size: (CGSize) imgSize;

@end
