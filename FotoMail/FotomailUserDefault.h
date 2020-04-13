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
+(instancetype _Nonnull ) defaults;


//propriétés sauvegardés
@property(nonatomic) bool timeStamp;
@property(nonatomic) float stampSize;
/// les adresses e-mails des destinataires (le tableau peut être vide)
@property(nonatomic, nonnull) NSArray<NSString *> *recipients;
/// les projets prédéfinis (le tableau peut être vide)
@property(nonatomic, nonnull) NSArray<NSString *> *projects;
///le projet en cours (en lecture, contient le \ final, en écriture ne pas le mettre), peut être une chaine vide devant le slash
@property(nonatomic, nonnull)  NSString  *currentProject;
/// le numéro incrémental pour numéroter les photos prises (est incrémenté par nextName)
@property (nonatomic) NSUInteger imgNumber;


// valeurs non sauvegardées

/// le nb d'images prises (n'est pas incrémenté automatiquement)
@property(nonatomic) int nbImages;
/// le titre edité dans le textField (sans n°)
@property(nonatomic, nonnull) NSString *titreImg;
///le nom de fichier des photos
@property(readonly, nonatomic, nonnull) NSString *nomImg;
/// les adresses e-mail des destinataires incluant le projet courant en extension, peut être un tableau vide
@property(readonly, nonnull) NSArray<NSString *> *recipientsWithExtension;

/// incrémente le N° incrémental du nom
-(void)nextName;
-(void)prepareUndo;
-(void)commitUndo;
/// remet à zéro le nb d'image en cours (nbImages ) et le titre (titreImg)
-(void)resetImageAndTitle;

@end
