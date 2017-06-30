//
//  editingImageView.m
//  FotoMail
//
//  Created by Alistef on 25/07/2016.
//  Copyright © 2016 garfromDev. All rights reserved.
//

#import "editingImageView.h"
#import "FotoMail-Bridging-Header.h"
#import "FotoMail-Swift.h"
#import "UIImage+timeStamp.h"
#import "float.h"


@implementation OverPath
-(id) initWithDrawColor: (UIColor *)color rubber: (BOOL)rubber
{
    self = [super init];
    if(self){
        self.path = [[UIBezierPath alloc] init];
        self.drawColor = color;
        self.rubber = rubber;
    }
    return self;
}

@end


/**
 Cette classe implémente un UIImageView incorporé dans un UISCrollView (qui est sa supervue)
 qui permet de dessiner en rouge par dessus
 Pour des raisons de performance, pendant l'édition, la scroll view est cachée et le dessin
 a lieu dans une autre vue . C'est le délégué qui gère ces aspects
 
 cycle :
 1) Idle
    prepareDisplay()    apparition de la preview
 2)preparingBig
    bloc completed on prepareBigQueue
 3) bigPrepared         l'image originelle + le tableau de path initialisé
    TouchBegan:
 4) preparingEdit       on crée un path vierge ajouté au tableau
    prepareDrawing completed on prepareBigQueue
 5) editprepared
 6) isDrawing
        TouchEnded: || TouchCancelled:
 7) saving              tous les path sont rendus dans l'image originelle

 */



@implementation EditingImageView
#define TIMETODRAW 0.02


BOOL delegateRequested; //mémorize le fait d'avoir envoyé editingRequested au delegate, pour éviter les appels multiples
BOOL  isDrawing;        // mode dessin activé, permet d'éliminer la première touche pour éviter un grand trait au début

NSTimeInterval finishPreparing; //the time (startupTime) at which the drawing preparation is finished

dispatch_queue_t prepareBigQueue;
dispatch_queue_t drawBigQueue;
dispatch_group_t prepareGroup;
dispatch_group_t drawBigGroup;

CGContextRef bigContext, smallContext; //les contextes graphiques de l'image taille réelle et de l'image d'affichage
CGFloat scale;          // initialisé par prepareDrawing avec la scale de la scrollview fournie par le delegué
CGPoint contentOffset;  // initialisé par prepareDrawing avec le content offset de la scrollview fournie par le delegué
CGSize displaySize;     // initialisé par prepareDrawing avec la taille de l'affichage fournie par le delegué
__weak UIScrollView *scrollView ; //référence sur la scrollview fournie par le delegue



#pragma mark interaction avec le vue controleur
// 1->2
-(void) prepareDisplay{
    
    // création des queues et des groupes
    
     static dispatch_once_t onceToken;
     dispatch_once(&onceToken, ^{
     prepareBigQueue = dispatch_queue_create("com.GarfromDev.Fotomail.prepareBigQueue", DISPATCH_QUEUE_SERIAL);
     drawBigQueue = dispatch_queue_create("com.GarfromDev.Fotomail.drawBigQueue", DISPATCH_QUEUE_SERIAL);
     prepareGroup = dispatch_group_create();
     drawBigGroup = dispatch_group_create();
     });

    //initialisation du tableau de paths (vide)
    self.overPaths = [[NSMutableArray<OverPath*> alloc] init];
    
    //réinitialiser l'image
//    self.image = nil; //FIXME: pas besoin si normalement l'image est vide au début
    
}


/* fin d'un cycle de preview :
 - on 
*/
-(void)endDisplay{
    LOG
    //note : on ne peut pas libérer self.image, car il va être lu par le controleur pour utiliser l'image
    self.overPaths = [[NSMutableArray<OverPath*> alloc] init];
    self.image = nil;
}


#pragma mark gestion des touches utilisateurs
// on de démarre le mode drawing que si la vue n'a pas commencé un mouvement de scroll, donc après un délai
-(void) touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSLog(@"Touch Began  ");
    finishPreparing = DBL_MAX; //sera remisà l'heure par prepareDrawing
    dispatch_group_notify(prepareGroup, prepareBigQueue, ^{
        [self prepareDrawing]; //prépare la petite image d'affichage rapide
        NSLog(@"Touch Began : drawing prepared at %@ ",[NSDate date]);
    });

}

/** déplacement du doigt
*/
-(void) touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
//    LOG
    __block UITouch *touch = [touches anyObject];
    //__block UIImage *rubberImg = originaleImg; //on mémorise la référence sur l'image originelle pour les appels de bloc en dispatch queue
    
    // on ne prend pas en compte les touches datant d'avant la fin de la préparation, pour éviter le grand trait droit à cause du gel de l'UI
    if(touch.timestamp < finishPreparing) { return; };

    // transmet l'info au délégué, une seule fois
    if(!delegateRequested){
        delegateRequested = true; //pour éviter un deuxième appel car plusieurs évènement de touches sont transmis
        [self.delegate editingRequested:self ]; //va afficher l'image petite au lieu du scroll view
    }
    isDrawing = true;

    //on met à jour la grande image en tache de fond
    CGPoint point1 = [touch previousLocationInView:self];
    CGPoint point2 = [touch locationInView:self];
    
    // 1 dessin dans le path (la couleur est initialisée dans le prepareDrawing
    OverPath *p = self.overPaths.lastObject;
    if(p.path.isEmpty){
        if(p.rubber){
            CGContextRef context = UIGraphicsGetCurrentContext();
            CGContextSetBlendMode(context, kCGBlendModeDestinationOut);
            [UIColor.whiteColor setStroke];
            p.path.lineWidth = DEFAULT_RUBBER_THICKNESS;
        }else{
            [p.drawColor setStroke];
            p.path.lineWidth = DEFAULT_THICKNESS;
        }
        p.path.lineJoinStyle = kCGLineJoinRound;
        p.path.lineCapStyle = kCGLineCapRound;
        [ p.path moveToPoint:point1];
    }
    
    [p.path addLineToPoint:point2];
    
    //on dessine dans la scroll view, donc les coordonnées sont bonnes pour la bigImage

    //2 on indique au délégué de metre à jour l'affichage de la vue réduite
    [self.delegate updateDisplayWithTouch: touch  paths:self.overPaths];

}


/// l'utilisateur a levé le doigt
-(void) touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSLog(@"Touch Ended view %ld ", (long)self.tag);
    [self stopEditing];
}


/// la scroll view a cancellé
- (void) touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSLog(@"Touch Cancelled");
    [self stopEditing];
}

#pragma mark cycle de vie

/* appellé par TouchBegan
 initialise la zone d'affichage pour le dessin à l'écran
 */
-(void) prepareDrawing
{
    NSLog(@"preparing drawing");

    //préparation petite image
    displaySize = [self.delegate getDisplaySize];
    //on crée le contexte qui va servir au réaffichage rapide de la partie visible
    UIGraphicsBeginImageContext(displaySize);
    smallContext = UIGraphicsGetCurrentContext();
    scrollView = [self.delegate getScrollView];
    scale = scrollView.zoomScale;
    contentOffset = scrollView.contentOffset;
    NSLog(@"drawing to small context width %f height %f scale %f", displaySize.width, displaySize.height, scale);

    //on récupère la partie visible de l'image au niveau de zoom actuel, elle est plus grande que l'écran en fonction du zoom
    // on la dessine dans le smallContext en la mettant à l'échelle
    CGContextTranslateCTM(smallContext, -contentOffset.x, -contentOffset.y);
    CGContextScaleCTM(smallContext, scale, scale);
    [self.backView.image drawAtPoint:CGPointZero];
//    CGContextDrawLayerAtPoint(smallContext, CGPointZero, drawLayer);
    
    UIImage *smallImage = UIGraphicsGetImageFromCurrentImageContext();
//    CGContextRestoreGState(bigContext);
    
    //2 libération du contexte
    UIGraphicsEndImageContext();
    
    // ajout d'un path pour stocker les ajouts
    OverPath *newOverPath = [[OverPath alloc] initWithDrawColor:self.drawingColor rubber:self.rubberON];
    [self.overPaths addObject:newOverPath];
    
    //on met à jour la vue d'affichage
    [self.delegate initViewWithImage: smallImage
                                scale:scale
                                offset:CGPointMake(self.frame.origin.x, self.frame.origin.y)
                                contentOffset: contentOffset
                                overPaths: self.overPaths ];
    // quand l'image est plus petite dans un sens, l'editingImageView est plus petite que la scrollView (contraintes réglées dans upDateConstraintForSize() du UIScrollViewDelegate
    //l'origine de sa frame représente donc l'offset par rapport à la superVue = ScrollView
    
    //on note l'heure de fin, cela servira dans TouchMoved pour éliminer les touches effectuées pendant que le contexte n'est pas prêt
    finishPreparing = [[NSProcessInfo processInfo] systemUptime];
    NSLog(@"drawing prepared");
}



/// quitte le mode edition, rend les path dans une image et rend la main à la scrollview
-(void) stopEditing
{
    LOG

    if(isDrawing){
        // on génère l'image transparente avec les paths à superposer à l'image originale
        self.image = [self createOverPathImage];
        isDrawing = false;
        [self.delegate editingFinished:self];
        delegateRequested = false;
    }

}


/// créee une image à partir de l'image originelle et des paths et la transmet à completion qui est appellée sur la main queue
- (void) saveEditedWithImage: (UIImage *)originaleImg completion:(void(^)(UIImage *finalImg)) completion
{
    LOG
    
    
    // situation de départ , on a
    // - image originelle
    // - les paths
    
    // 1 créer une image à fond noir
    NSLog(@"1 créer une image à fond noir");
    UIGraphicsBeginImageContextWithOptions(originaleImg.size, YES, originaleImg.scale);
    CGContextRef pathContext = UIGraphicsGetCurrentContext();
    UIBezierPath *r = [UIBezierPath bezierPathWithRect:self.bounds];
    [UIColor.blackColor set];
    [r stroke];
    [r fill];
    CGContextTranslateCTM(pathContext, 0.0, originaleImg.size.height);
    CGContextScaleCTM(pathContext, 1.0, -1.0);
    
    // 2 dessiner les path dans une image pathImage en couleur blanche, gomme en noire
    for( OverPath *p in self.overPaths){
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
    NSLog(@"creating mask");
    CGImageRef msq = CGImageMaskCreate( originaleImg.size.width,
                                       originaleImg.size.height,
                                       1,
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
    for( OverPath *p in self.overPaths){
        NSLog(@"drawing path with rubber %@", p.rubber ? @"ON" : @"OFF");
        if(!p.rubber){
            [p.drawColor set];
            [p.path stroke];
        }
    }
    // 5 appliquer clipToMask
    // il faut des valeurs de 1 (blanc) là où l'image originelle doit apparaitre
    // il faut des valeurs de 0 (noir) là ou les path doivent apparaitres
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
    __block UIImage *finalImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    NSLog(@"calling completinon");
    dispatch_async(dispatch_get_main_queue(), ^{
        completion(finalImg);
    });
    
    NSLog(@"saving finished");
    
}


-(void) undoEditing{
    NSLog(@"undo Editing...");
    if(delegateRequested){
        isDrawing = false;
        delegateRequested = false;
        [self.delegate editingFinished:self];
    }
    // on n'appelle pas endDisplay, car sinon il efface originaleImg
    self.image = nil;
    self.overPaths = [[NSMutableArray<OverPath*> alloc ] init];
    [self prepareDisplay]; //reconstruit la CGLayer pour nouveau cycle
}


- (UIImage *)createOverPathImage{
    // 1 création du contexte
    NSLog(@"1 créer une image transparente");
    UIGraphicsBeginImageContextWithOptions(self.backView.image.size, NO, self.backView.image.scale);

    // 2 dessiner les path
    for( OverPath *p in self.overPaths){
        NSLog(@"drawing path into image with rubber %@", p.rubber ? @"ON" : @"OFF");
        if(!p.rubber){
            [p.drawColor set];
        }else{
            [UIColor.clearColor set];
        }
        [p.path stroke];
    }
    
    // 3 récupérer l'image
    UIImage *overPathImg =  UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return overPathImg;
}


#pragma mark fonctions utiles
///  trace une ligne entre 2 points dans le contexte donnée
+ (void) drawLineFrom: (CGPoint) point1 to: (CGPoint) point2 thickness: (CGFloat) t inContext: (CGContextRef)context {
    NSLog(@"draw line from %f %f to %f %f", point1.x, point1.y, point2.x, point2.y);
    CGContextSaveGState(context);
    CGContextSetStrokeColorWithColor(context, UIColor.redColor.CGColor);
    CGContextSetLineWidth(context, t);
    CGContextSetLineJoin(context, kCGLineJoinRound);
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, point1.x , point1.y );
    CGContextAddLineToPoint(context, point2.x , point2.y );
    CGContextStrokePath(context);
    CGContextRestoreGState(context);

}


// extrait une zone donnée d'une image
+(UIImage *)imageFromImage: (UIImage *)srcImage inRect: (CGRect) rect
{
    return [srcImage croppedImageInRect:rect]; //déclaré dans UIImage+TimeStamp
}

- (UIImage *)visibleImage {
    //on récupère la partie visible de l'image de la scrollView au niveau de zoom actuel
    CGRect visibleRect;
    CGFloat iscale = 1.0 / scale;
    visibleRect.origin.x = contentOffset.x * iscale;
    visibleRect.origin.y = contentOffset.y * iscale;
    visibleRect.size.width = scrollView.bounds.size.width * iscale;
    visibleRect.size.height = scrollView.bounds.size.height * iscale;
    return [EditingImageView imageFromImage:self.image inRect: visibleRect];
}



@end
