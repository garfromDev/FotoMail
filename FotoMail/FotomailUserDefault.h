//
//  FotomailUserDefault.h
//  FotoMail
//
//  Created by Alistef on 31/12/2016.
//  Copyright © 2016 garfromDev. All rights reserved.
//

#import <Foundation/Foundation.h>
/// Fourni un accès aux préférence utilisateur, indépendant de l'implémentation
@interface FotomailUserDefault : NSObject
/// le singleton
+(instancetype) defaults;


//propriétés sauvegardés
@property(nonatomic) bool timeStamp;
@property(nonatomic) float stampSize;
@property(nonatomic) NSArray<NSString *> *recipients;
/// le numéro incrémental pour numéroter les photos prises
@property (nonatomic) NSUInteger imgNumber;


// valeurs non sauvegardées

/// le nb d'images prises
@property(nonatomic) int nbImages;
/// le titre edité dans le textField (sans n°)
@property(nonatomic) NSString *titreImg;
///le nom de fichier des photos
@property(readonly, nonatomic) NSString *nomImg;
/// incrémente le N° incrémental du nom
-(void)nextName;
-(void)prepareUndo;
-(void)commitUndo;
/// remet à zéro le nb d'image en cours (nbImages ) et le titre (titreImg)
-(void)resetImageAndTitle;

@end
