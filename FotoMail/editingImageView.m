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

// sauvegarde de l'image originale pour le undo
UIImage *originaleImg;

/// la layer utilisée pour le dessin à l'échelle 1 de la big image
CGLayerRef drawLayer;


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
    
    // préparation de la layer pour le dessin à l'échelle 1
    dispatch_group_async(prepareGroup, prepareBigQueue, ^{
        // création du contexte big
        UIGraphicsBeginImageContext(self.bounds.size);
        CGContextRef myContext = UIGraphicsGetCurrentContext();
        // création de la couche (mémorisée dans la variable d'instance)
        //on commence par relaese pour le cas où elle existe déjà (undo)
        
        drawLayer = CGLayerCreateWithContext(myContext, self.bounds.size, NULL);
        // libération du contexte
        UIGraphicsEndImageContext();
        
        // dessin de la grande image dans la couche
        bigContext = CGLayerGetContext(drawLayer);
        UIGraphicsPushContext(bigContext);
        [self.image drawAtPoint:CGPointZero];
        UIGraphicsPopContext();
        
        //mémorisation de l'image pour le undo
        originaleImg = [self.image copy]; //l'image est à l'envers
        
        //initialisation du tableau de paths (vide)
        self.overPaths = [[NSMutableArray<OverPath*> alloc] init];
    });
    
}


-(void)endDisplay{
    LOG
    //on release la layer, qui sera recréee par prepareDisplay
    // avec éventuellement des paramètres différents
    CGLayerRelease(drawLayer);
    //note : on ne peut pas libérer self.image, car il va être lu par le controleur pour utiliser l'image
    originaleImg = nil; //par contre on libère la copie
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
    LOG
    __block UITouch *touch = [touches anyObject];
    __block UIImage *rubberImg = originaleImg; //on mémorise la référence sur l'image originelle pour les appels de bloc en dispatch queue
    
    // on ne prend pas en compte les touches datant d'avant la fin de la préparation, pour éviter le grand trait droit à cause du gel de l'UI
    if(touch.timestamp < finishPreparing) { return; };

    // transmet l'info au délégué, une seule fois
    if(!delegateRequested){
        delegateRequested = true; //pour éviter un deuxième appel car plusieurs évènement de touches sont transmis
        [self.delegate editingRequested:self withLayer:drawLayer]; //va afficher l'image petite au lieu du scroll view
    }
    isDrawing = true;

    //on met à jour la grande image en tache de fond
    CGPoint point1 = [touch previousLocationInView:self];
    CGPoint point2 = [touch locationInView:self];
    
    //TODO: à remplacer par dessin dans le path (la couleur est initialisée dans le prepareDrawing
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
//    if(!self.rubberON){ //mode dessin
//        dispatch_group_async(drawBigGroup, drawBigQueue, ^{
//            [EditingImageView drawLineFrom:point1 to:point2 thickness:DEFAULT_THICKNESS  inContext:bigContext];
//        });
//    }else{ //mode gomme
//        // on dessine l'image à l'origine, avec un clipage
//        dispatch_group_async(drawBigGroup, drawBigQueue, ^{
//            [UIView eraseFrom:point1 to:point2 thickness:(CGFloat) DEFAULT_RUBBER_THICKNESS context:bigContext rubberImg:rubberImg];
//        });
//    }
//    
    //2 on indique au délégué de metre à jour l'affichage de la vue réduite
    [self.delegate updateDisplayWithTouch: touch withRubberOn:self.rubberON paths:self.overPaths];

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
    CGContextSaveGState(bigContext);
    CGContextTranslateCTM(smallContext, -contentOffset.x, -contentOffset.y);
    CGContextScaleCTM(smallContext, scale, scale);
    CGContextDrawLayerAtPoint(smallContext, CGPointZero, drawLayer);
    UIImage *smallImage = UIGraphicsGetImageFromCurrentImageContext();
    CGContextRestoreGState(bigContext);
    
    //2 libération du contexte
    UIGraphicsEndImageContext();
    
    // ajout d'un path pour stocker les ajouts
    OverPath *newOverPath = [[OverPath alloc] initWithDrawColor:self.drawingColor rubber:self.rubberON];
    [self.overPaths addObject:newOverPath];
    
    //on met à jour la vue d'affichage
    [self.delegate initViewWithImage:smallImage
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



/// quitte le mode edition, met fin au contexte graphique et rend la main à la scrollview
-(void) stopEditing
{
    LOG
    //on remet la bigImage dans la scrollView si une édition a eu lieu, le  big layer est conservé intact
    if(isDrawing){
        [self saveEditedImage: ^{ [self.delegate editingFinished:self];} ];
    } else {
        [self.delegate editingFinished:self];
    }
    
    isDrawing = false;
    delegateRequested = false;
  
}


/// créee une image à partir du bigContext et la met dans self.image (la scroolView), completion est appellée sur la main queue
- (void) saveEditedImage: (dispatch_block_t) completion
{
    LOG
    // fait dans la mainQueue sinon l'affectation de self.image n'ets pas rendu
    // le group_notify permet d'être sur que toutes les taches de dessins sont terminées sur la drawBigQueue
    dispatch_group_notify(drawBigGroup, dispatch_get_main_queue(), ^{
        UIGraphicsBeginImageContext(self.bounds.size);
        CGContextRef currentContext = UIGraphicsGetCurrentContext();
        [UIColor.clearColor set];
        CGContextFillRect(currentContext, self.bounds);
        NSLog(@"background cleared...");
//        CGContextDrawLayerAtPoint(currentContext, CGPointZero, drawLayer);
//        [originaleImg drawAtPoint:CGPointZero];
        //TODO: rendre les paths
        for( OverPath *p in self.overPaths){
            NSLog(@"drawing path with rubber %@", p.rubber ? @"ON" : @"OFF");
            if(p.rubber){
                CGContextSetBlendMode(currentContext, kCGBlendModeDestinationOut);
                [UIColor.whiteColor set];
            }else{
                CGContextSetBlendMode(currentContext, kCGBlendModeNormal);
                [p.drawColor setStroke];
            }
            [p.path stroke];
        }
        NSLog(@"getting path image...");
        CGImageRef overpathImg = CGBitmapContextCreateImage(currentContext);
        
        CGContextScaleCTM(currentContext, -1, -1);
        NSLog(@"drawing originale image...");
//        CGContextSetBlendMode(currentContext, kCGBlendModeNormal);
//        [originaleImg drawAtPoint:CGPointZero];
        CGContextDrawImage(currentContext, self.bounds, originaleImg.CGImage);
        
        NSLog(@"drawing path image...");
        CGContextDrawImage(currentContext, self.bounds, overpathImg);
        
        NSLog(@"getting composite image...");
        self.image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        dispatch_async(dispatch_get_main_queue(), ^{
            completion();
        });
        
        NSLog(@"saving finished");
    });
}


-(void) undoEditing{
    NSLog(@"undo Editing...");
    if(delegateRequested){
        isDrawing = false;
        delegateRequested = false;
        [self.delegate editingFinished:self];
    }
    // on n'appelle pas endDisplay, car sinon il efface originaleImg
    self.image = originaleImg;
    CGLayerRelease(drawLayer);
    [self prepareDisplay]; //reconstruit la CGLayer pour nouveau cycle
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
