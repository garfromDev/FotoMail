//
//  editingImageView.h
//  FotoMail
//
//  Created by Alistef on 25/07/2016.
//  Copyright © 2016 garfromDev. All rights reserved.
//

#import <UIKit/UIKit.h>


/**
 Cette classe implémente un UIImageView incorporé dans un UISCrollView
 qui permet de dessiner en rouge par dessus
 */
@class EditingImageView;

@protocol EditingImageViewController
// will be called to inform the delegetae that editing has been requested on  EditingImageView
- (void) editingRequested: (EditingImageView *)fromView withLayer:(CGLayerRef)drawLayer;

// will be called to inform the delegetae that editing has been finished on  EditingImageView
- (void) editingFinished: (EditingImageView *)fromView;

// delegate must returns display aera size
- (CGSize) getDisplaySize;

// delegate must return reference to scrollview (he must keep strong reference on it)
- (UIScrollView *) getScrollView;

// ask delegate to update display aera with line information
-(void) updateDisplayWithTouch: (UITouch *)touch;

//ask delegate to initialize of drawing view with initial image
-(void) initViewWithImage: (UIImage *)image scale: (CGFloat)scale offset: (CGPoint)offset;

@end

@interface EditingImageView : UIImageView


@property( weak) id<EditingImageViewController> delegate;

/// Prepare the copy of the image and the context, must be called before the user interact with the view
- (void) prepareDisplay;
/// ask EditingImageView to actualize self.image with memorized drawings and call completion on mainQueue
- (void) saveEditedImage: (dispatch_block_t) completion;
/// forgot drawing and switch back to originale image (at the time of prepareDisplay)
- (void) undoEditing;
/// release the ressource used for editing, must be called symetrcial to prepareDisplay
- (void) endDisplay;

/// 
+ (UIImage *)imageFromImage: (UIImage *)srcImage inRect: (CGRect) rect;
+ (void) drawLineFrom: (CGPoint) point1 to: (CGPoint) point2 thickness: (CGFloat) t inContext: (CGContextRef)context;

@end
