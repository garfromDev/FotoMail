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

#define DEFAULT_THICKNESS 30.0

/**
 Cette classe implémente un UIImageView incorporé dans un UISCrollView (qui est sa supervue)
 qui permet de dessiner en rouge par dessus
 Pour des raisons de performance, pendant l'édition, la scroll view est cachée et le dessin
 a lieu dans une autre vue . C'est le délégué qui gère ces aspects
 
 cycle :
 waiting
 prepareEditing
 isDrawingPrepared
 TouchBegan
 isDrawing
stopEditing
 waiting
 */



@implementation EditingImageView
#define TIMETODRAW 0.02


BOOL delegateRequested; //mémorize le fait d'avoir envoyé editingRequested au delegate, pour éviter les appels multiples
BOOL  isDrawing;        // mode dessin activé, permet d'éliminer la première touche pour éviter un grand trait au début
BOOL isDrawingPrepared; //la préparation des images pour le dessin est faite
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

CGLayerRef drawLayer;

/// chaque fois qu'une nouvelle image est affectée, on prépare
/*2
-(void)setImage:(UIImage *)newimage{
    LOG
    [super setImage:newimage];
    [self prepareBigImage];
}
*/

#pragma mark gestion des touches utilisateurs
/* pourrais être utilisé pour anticiper la préparation
-(void) prepareEditing{
    LOG
    if(isDrawing)  { return; }
    if(isDrawingPrepared) { [self stopEditing]; }
    //[self prepareDrawing];
}
*/

-(void) prepareDisplay{
    
    // création des queues et des groupes
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        prepareBigQueue = dispatch_queue_create("com.GarfromDev.Fotomail.prepareBigQueue", DISPATCH_QUEUE_SERIAL);
        drawBigQueue = dispatch_queue_create("com.GarfromDev.Fotomail.drawBigQueue", DISPATCH_QUEUE_SERIAL);
        prepareGroup = dispatch_group_create();
        drawBigGroup = dispatch_group_create();
    });
    
    dispatch_group_async(prepareGroup, prepareBigQueue, ^{
        // création du contexte big
        UIGraphicsBeginImageContext(self.bounds.size);
        CGContextRef myContext = UIGraphicsGetCurrentContext();
        //2 création de la couche (mémorisée dans la variable d'instance)
        drawLayer = CGLayerCreateWithContext(myContext, self.bounds.size, NULL);
        
        //2 libération du contexte
        UIGraphicsEndImageContext();
        
        //2 dessin de la grande image dans la couche (pourrais être mis en tache de fond)
        bigContext = CGLayerGetContext(drawLayer);
        UIGraphicsPushContext(bigContext);
        [self.image drawAtPoint:CGPointZero];
        UIGraphicsPopContext();

    });
    
}


-(void)endDisplay{
    CGLayerRelease(drawLayer);
    self.image = nil;
    
}
// on de démarre le mode drawing que si la vue n'a pas commencé un mouvement de scroll, donc après un délai
-(void) touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSLog(@"Touch Began  ");
    // on évite les double préparations
    //2 if(isDrawingPrepared){ return; };
    [self prepareDrawing]; //prépare la petite image d'affichage rapide
    NSLog(@"Touch Began : drawing prepared at %@ ",[NSDate date]);
}

/** déplacement du doigt
 on ne prend en compte
 après une tempo de TIMETODRAW sec pour éviter les traits involontaires */
-(void) touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    LOG
    __block UITouch *touch = [touches anyObject];

    // on ne prend pas en compte les touches datant d'avant la fin de la préparation, pour éviter le grand trait droit à cause du gel de l'UI
    if(touch.timestamp < finishPreparing) { return; };

    // transmet l'info au délégué, une seule fois
    
    if(!delegateRequested){
        delegateRequested = true; //pour éviter un deuxième appel car plusieurs évènement de touches sont transmis
        [self.delegate editingRequested:self withLayer:drawLayer]; //va afficher l'image petite au lieu du scroll view
    }
    
    if(!isDrawing) { //pour éviter un grand trait si le doigt bougeait avant expiration du délai, la 1ere touche est supprimée
        isDrawing = true;
        return;
    }
    
    //on met à jour la grande image en tache de fond
    //2 dispatch_async(bigImgQueue, ^{
        CGPoint point1 = [touch previousLocationInView:self];
        CGPoint point2 = [touch locationInView:self];
        
        //on dessine dans la scroll view, donc les coordonnées sont bonnes pour la bigImage
        [EditingImageView drawLineFrom:point1 to:point2 thickness:DEFAULT_THICKNESS  inContext:bigContext];
    //2 });
    
    //2 on indique au délégué de metre à jour l'affichage de la vue réduite
    [self.delegate updateDisplayWithTouch: touch];
    //on indique à la vue de se remttre à jour
    //CGRect drawRect = CGRectMake(point1.x, point1.y, fabs(point2.x-point1.x), fabsf(point2.y-point1.y));
    //[self setNeedsDisplayInRect:CGRectInset(drawRect, -DEFAULT_THICKNESS, -DEFAULT_THICKNESS)]; //NOTE : si l'épaisseur devient variable, il faudra en tenir compte
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
   mémorize les informations de la scroll view et crée les contextes graphiques
 initialise la zone d'affichage
 */
-(void) prepareDrawing //attention en cours de transformation
{
    NSLog(@"preparing drawing");
    finishPreparing = DBL_MAX; //poue être sur que la valeur sera considérée comme non dépassée, tant qu'on ne l'a pas mis à la date de fin
   isDrawingPrepared = false;
/*
    //on crée le contexte qui va servir au réaffichage rapide de la partie visible
    NSLog(@"preparing context %f by %f", self.bounds.size.width, self.bounds.size.height);
        displaySize = [self.delegate getDisplaySize];
    UIGraphicsBeginImageContext(displaySize);
    smallContext = UIGraphicsGetCurrentContext();
    //TODO: voir à remplacer par un draw de CGLayer avec scale et translate
    //on récupère la partie visible de l'image au niveau de zoom actuel, elle est plus grande que l'écran en fonction du zoom
    NSLog(@"getting visible image");
    scrollView = [self.delegate getScrollView];
    scale = scrollView.zoomScale;
    contentOffset = scrollView.contentOffset;
    UIImage *smallImageContent = [self visibleImage];

    // on la dessinne dans le smallContext en la mettant à l'échelle
    NSLog(@"drawing to small context width %f height %f scale %f", displaySize.width, displaySize.height, scale);
    //CGContextSaveGState(smallContext);
    CGContextScaleCTM(smallContext, scale, scale);
    [smallImageContent drawAtPoint:CGPointZero];
    NSLog(@"getting image from small context");
    UIImage *smallImage = UIGraphicsGetImageFromCurrentImageContext();
   
    //CGContextRestoreGState(smallContext);
    UIGraphicsEndImageContext();
    CGContextRelease(smallContext);
    
    /*2
    //UIGraphicsBeginImageContextWithOptions(displaySize , YES, 0.0 );
    UIGraphicsBeginImageContext(displaySize);
    smallContext = UIGraphicsGetCurrentContext();

 
   
    //2 création du contexte big
    UIGraphicsBeginImageContext(self.bounds.size);
    CGContextRef myContext = UIGraphicsGetCurrentContext();
    //2 création de la couche (mémorisée dans la variable d'instance)
    drawLayer = CGLayerCreateWithContext(myContext, self.bounds.size, NULL);
    
    //2 libération du contexte
    UIGraphicsEndImageContext();
    
    //2 dessin de la grande image dans la couche (pourrais être mis en tache de fond)
    bigContext = CGLayerGetContext(drawLayer);
    UIGraphicsPushContext(bigContext);
    [self.image drawAtPoint:CGPointZero];
    UIGraphicsPopContext();
    */
    //préparation petite image V2
    CGContextSaveGState(bigContext);
    displaySize = [self.delegate getDisplaySize];
    UIGraphicsBeginImageContext(displaySize);
    smallContext = UIGraphicsGetCurrentContext();
    scrollView = [self.delegate getScrollView];
    scale = scrollView.zoomScale;
    contentOffset = scrollView.contentOffset;
    //CGFloat iScale=1/scale;
    //CGRect visibleRect = CGRectMake(contentOffset.x * iScale, contentOffset.y *iScale, displaySize.width * iScale, displaySize.height * iScale);
    //CGContextScaleCTM(smallContext, scale, scale);

    CGContextTranslateCTM(smallContext, -contentOffset.x, -contentOffset.y);
    CGContextScaleCTM(smallContext, scale, scale);
    //CGContextClipToRect(bigContext, visibleRect);
    CGContextDrawLayerAtPoint(smallContext, CGPointZero, drawLayer);
    UIImage *smallImage = UIGraphicsGetImageFromCurrentImageContext();
    CGContextRestoreGState(bigContext);
    UIGraphicsEndImageContext();
    CGContextRelease(smallContext);
    
    // autre possibilité : CG
    //on met à jour la vue d'affichage
    [self.delegate initViewWithImage:smallImage scale:scale offset:CGPointMake(self.frame.origin.x, self.frame.origin.y)];
    // quand l'image est plus petite dans un sens, l'editingImageView est plus petite que la scrollView (contraintes réglées dans upDateConstraintForSize() du UIScrollViewDelegate
    //l'origine de sa frame représente donc l'offset par rapport à la superVue = ScrollView
    
    isDrawingPrepared = true;
    finishPreparing = [[NSProcessInfo processInfo] systemUptime];
    NSLog(@"drawing prepared");
}
/*
-(void)prepareBigImage{
    // on crée le contexte qui va servir à dessiner le trait rouge big Image
    // ceci se fait dans la serial queue bigQueue pour assurer que le contexte est prêt avant de dessiner dedans
   LOG
    //on créee la queue si cela n'a pas déjà été fait

    
    dispatch_async(bigImgQueue, ^{
        //on sauvegarde l'image
        NSLog(@"preparing big image...");
        originaleImg = [self.image copy];
        CGContextRelease(bigContext);
        UIGraphicsBeginImageContext(self.bounds.size);
        bigContext = UIGraphicsGetCurrentContext();
        CGContextSetLineCap(bigContext, kCGLineCapRound);
        [self.image drawAtPoint:CGPointZero];
        NSLog(@"big image prepared");
    });
    
}
*/

/// quitte le mode edition, met fin au contexte graphique et rend la main à la scrollview
-(void) stopEditing
{
    LOG
    //on remet la bigImage dans la scrollView si une édition a eu lieu, le saveEditedImage détruira le big context et en recréera un nouveau
    if(isDrawing){
        [self saveEditedImage];
    }
    //sinon le big context reste présent
    
    isDrawing = false;
    isDrawingPrepared = false;
    delegateRequested = false;

    [self.delegate editingFinished:self];
    
    //[self prepareDrawing]; abondonné, le temps de préparation rend moins fluide les scrolls
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

// créee une image à partir du bigContext et la met dans self.image (la scroolView)
- (void) saveEditedImage
{
    LOG
 
    UIGraphicsBeginImageContext(self.bounds.size);
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    //CGContextScaleCTM(currentContext, 1.0, -1.0);
    CGContextDrawLayerAtPoint(currentContext, CGPointZero, drawLayer);
    self.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    //CGLayerRelease(drawLayer);
        /*2 UIGraphicsEndImageContext();
        self.image = [UIImage imageWithCGImage:imgCG]; //2 setImage va recréer un nouveau grand contexte
        CGImageRelease(imgCG);


*/
}


/*-(void) drawRect:(CGRect)rect{
    NSLog(@"draw rect (%f - %f) w: %f  h:%f", rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    CGContextSaveGState(bigContext);
    CGContextClipToRect(bigContext, rect);
    CGContextDrawLayerInRect(currentContext, rect, drawLayer);
    CGContextRestoreGState(bigContext);
}
*/

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

-(void) undoEditing{
    NSLog(@"undo Editing...");
    if(delegateRequested){
        isDrawing = false;
        delegateRequested = false;
        UIGraphicsEndImageContext();
        [self.delegate editingFinished:self];
    }
    self.image = originaleImg;
}


@end
