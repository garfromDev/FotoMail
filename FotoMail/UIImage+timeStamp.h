//
//  UIImage+timeStamp.h
//  FotoMail
//
//  Created by Alistef on 22/07/2016.
//  Copyright © 2016 garfromDev. All rights reserved.
//

#import <UIKit/UIKit.h>

// cette extension permet de rajouter un horodatage à une image
@interface UIImage (TimeStamp)

/*! add time stamp to an image
 @param fontSize the size of the fond to use
 @return
 @discussion timeSTamp is in blue color and at bottom left of the image
 it is formatted using local preferences
 */
- (UIImage *)addTimeStampWithFontSize: (int)fontSize;


/*! return a cropped sub-part of an image
 @param rect: the sub-rect to crop
 @return a new UIImage of the cropped region
 @discussion
 ATTENTION : no protection against too big, negative or null value, may crash
 @code
 @endcode
 */
- (UIImage *)croppedImageInRect:(CGRect)rect;

@end



@interface UIView(GetImage)

-(UIImage *)getUIImage;

@end
