//
//  editingImageView.h
//  FotoMail
//
//  Created by Alistef on 25/07/2016.
//  Copyright © 2016 garfromDev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PathMixer.h"

/**
 Cette classe implémente un UIImageView incorporé dans un UISCrollView
 qui permet de dessiner en rouge par dessus
 */
@class EditingImageView;
/*
// Déclaration d'un type regroupant le path et sa couleur
@interface OverPath : NSObject
@property(strong, nonatomic) UIBezierPath *path;
@property(strong, nonatomic) UIColor *drawColor;
@property BOOL rubber;
@end
*/
// protocol that mustbe respected by the delegate
@protocol EditingImageViewController

//ask delegate to initialize of drawing view with initial image
-(void) initViewWithImage: (UIImage *)image scale: (CGFloat)scale offset: (CGPoint)offset contentOffset: (CGPoint)contentOffset overPaths: (NSArray<OverPath*> *)overPaths;

// will be called to inform the delegate that editing has been requested on  EditingImageView
- (void) editingRequested: (EditingImageView *)fromView ;

// ask delegate to update display aera with line information
-(void) updateDisplayWithTouch: (UITouch *)touch paths: (NSArray<OverPath*> *) paths;

// will be called to inform the delegetae that editing has been finished on  EditingImageView
- (void) editingFinished: (EditingImageView *)fromView;

// delegate must returns display aera size
- (CGSize) getDisplaySize;

// delegate must return reference to scrollview (he must keep strong reference on it)
- (UIScrollView *) getScrollView;

@end



@interface EditingImageView : UIImageView

@property( weak) id<EditingImageViewController> delegate;
//@property( weak) UIImageView *backView;
/// l'image avec le dessin non édité
@property UIImage *originaleImage;

/// le tableau des ajouts dessinés à rajouter par dessus l'image
@property(nonatomic) NSMutableArray<OverPath *> *overPaths;
/// choix du mode dessin (False) ou gomme (True)
@property (nonatomic) BOOL rubberON;
@property UIColor *drawingColor;

/// Prepare the copy of the image and the context, must be called before the user interact with the view
- (void) prepareDisplay;

/*! called when review is closed with <Use>
 Generate the final image with the path overimposed
 @param fromImg the originale image
 @param completion : the block that will be called with the final image in parameter
 @return
 @discussion completion is called on main queue
 */
- (void) saveEditedWithImage: (UIImage *)originaleImg completion:(void(^)(UIImage *finalImg)) completion;

/// forgot drawing and switch back to originale image (at the time of prepareDisplay)
- (void) undoEditing;

/// release the ressource used for editing, must be called a tthe end of review process
- (void) endDisplay;

/// 
+ (UIImage *)imageFromImage: (UIImage *)srcImage inRect: (CGRect) rect;
+ (void) drawLineFrom: (CGPoint) point1 to: (CGPoint) point2 thickness: (CGFloat) t inContext: (CGContextRef)context;

@end
