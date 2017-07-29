//
//  UIImage+timeStamp.m
//  FotoMail
//
//  Created by Alistef on 22/07/2016.
//  Copyright © 2016 garfromDev. All rights reserved.
//

#import "UIImage+timeStamp.h"
#define LOG NSLog(@"%@",NSStringFromSelector(_cmd));

// cette extension permet de rajouter un horodatage à une image
@implementation UIImage (TimeStamp)

- (UIImage *)addTimeStampWithFontSize: (int) fontSize
{
    LOG
    UIImage *stampedImg;
    //UIGraphicsBeginImageContext(self.size);
    UIGraphicsBeginImageContextWithOptions(self.size, YES, 1.0);
    [self drawInRect:CGRectMake(0, 0, self.size.width, self.size.height)];
    NSDate *now = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateStyle = NSDateFormatterMediumStyle;
    formatter.timeStyle = NSDateFormatterMediumStyle;
    NSString *dateStr = [formatter stringFromDate:now];
    CGRect theSize;
    NSDictionary *attribute  = @{NSFontAttributeName :[UIFont systemFontOfSize:fontSize] , NSForegroundColorAttributeName : [UIColor blueColor]};
    theSize = [ dateStr boundingRectWithSize:CGSizeMake(self.size.width - 20.0, self.size.height - 20.0) options:NSStringDrawingUsesLineFragmentOrigin attributes:attribute context:nil];
    CGFloat y = self.size.height - theSize.size.height - (CGFloat) 20.0 ;
    CGRect zone = CGRectMake(20.0, y, theSize.size.width, theSize.size.height);
    
    [dateStr drawInRect:zone withAttributes:attribute];
    
    stampedImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return stampedImg;
}

//note : no UnitTest of croppedImage (not a problem within FotoMail use)
- (UIImage *)croppedImageInRect:(CGRect)rect
{
    double (^rad)(double) = ^(double deg) {
        return deg / 180.0 * M_PI;
    };
    
    //si rect est plus grand que image, on réduit rect à la taille de image (on ne grossis pas l'image)
    rect.size.width = MIN(rect.size.width, self.size.width);
    rect.size.height = MIN(rect.size.height, self.size.height);
    
    CGAffineTransform rectTransform;
    switch (self.imageOrientation) {
        case UIImageOrientationLeft:
            rectTransform = CGAffineTransformTranslate(CGAffineTransformMakeRotation(rad(90)), 0, -self.size.height);
            break;
        case UIImageOrientationRight:
            rectTransform = CGAffineTransformTranslate(CGAffineTransformMakeRotation(rad(-90)), -self.size.width, 0);
            break;
        case UIImageOrientationDown:
            rectTransform = CGAffineTransformTranslate(CGAffineTransformMakeRotation(rad(-180)), -self.size.width, -self.size.height);
            break;
        default:
            rectTransform = CGAffineTransformIdentity;
    };
    rectTransform = CGAffineTransformScale(rectTransform, self.scale, self.scale);
    
    CGImageRef imageRef = CGImageCreateWithImageInRect([self CGImage], CGRectApplyAffineTransform(rect, rectTransform));
    UIImage *result = [UIImage imageWithCGImage:imageRef scale:self.scale orientation:self.imageOrientation];
    CGImageRelease(imageRef);
    
    return result;
}
@end




@implementation UIView(GetImage)

-(UIImage *)getUIImage{
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, YES, 0.0f);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [self.layer renderInContext:context];
    UIImage *snapshotImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return snapshotImage;
}

@end
