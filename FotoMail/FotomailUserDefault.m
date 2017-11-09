//
//  FotomailUserDefault.m
//  FotoMail
//
//  Created by Alistef on 31/12/2016.
//  Copyright © 2016 garfromDev. All rights reserved.
//

#import "FotomailUserDefault.h"
#import "defines.h"

@implementation FotomailUserDefault

NSString *oldTitle;

+(instancetype) defaults
{
    static FotomailUserDefault *userDefaults;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        userDefaults = [[FotomailUserDefault alloc] init];
    });
    return userDefaults;
}


- (bool) timeStamp {
    return [[NSUserDefaults standardUserDefaults] boolForKey:TIMESTAMP];
}


- (void) setTimeStamp:(bool)timeStamp{
    [[NSUserDefaults standardUserDefaults] setBool:timeStamp forKey:TIMESTAMP];
}



- (NSArray<NSString *> *)recipients {
    NSArray *listRecipients = [[ NSUserDefaults standardUserDefaults] arrayForKey:RECIPIENTS];
    //il faut enlever le dernier, qui contient ""
    return [listRecipients subarrayWithRange:NSMakeRange(0, listRecipients.count -1)];
    }


- (void) setRecipients:(NSArray<NSString *> *)recipients{
    [[NSUserDefaults standardUserDefaults] setValue:recipients forKey:RECIPIENTS];
}


- (NSArray<NSString *> *)projects {
    NSArray *listProjects = [[ NSUserDefaults standardUserDefaults] arrayForKey:PROJECTS];
    return listProjects;
}


- (void) setProjects:(NSArray<NSString *> *)projects{
    [[NSUserDefaults standardUserDefaults] setValue:projects forKey:PROJECTS];
}


- (float)stampSize {
    return [[NSUserDefaults standardUserDefaults] floatForKey:STAMPSIZE];
}


- (void)setStampSize:(float)stampSize{
    [[NSUserDefaults standardUserDefaults] setFloat:stampSize forKey:STAMPSIZE];
}


///le nom de fichier des photos.
- (NSString *)nomImg {

    //les photos sont nommées d'après le titre si il existe, par défaut sinon
    // toujours avec un numéro incrémental à la fin
    if( self.titreImg.length > 0 ) {
        return [NSString stringWithFormat:@"%@_%lu.jpg", self.titreImg, (unsigned long)self.imgNumber];
    }else{
        return [NSString stringWithFormat:@"Foto_%lu.jpg",(unsigned long)self.imgNumber];
    }
}

/// retourne le titre en cours d'édition, une chaine vide si la propriété n'a pas été settée
- (NSString *)titreImg {
    if(_titreImg){
        return _titreImg;
    }
    return @"";
}

- (void)setImgNumber:(NSUInteger)nbImages {
    //protection contre le débordement
    [[NSUserDefaults standardUserDefaults] setInteger:nbImages < NSIntegerMax? nbImages : 0 forKey:IMGNUMBER];
    }


- (NSUInteger)imgNumber {
        return [[NSUserDefaults standardUserDefaults] integerForKey:IMGNUMBER];
    }

///incrémente le n° pour passer au nom suivant
-(void)nextName{
    LOG
    self.imgNumber++;
}

///mémorize le titre en cas d'undo
-(void)prepareUndo{
    oldTitle = [NSString stringWithString:self.titreImg];
}

/// restaure le titre suavegardé
-(void)commitUndo{
    self.titreImg = oldTitle;
}

/// remet à zéro le nb d'image en cours (nbImages ) et le titre (titreImg)
-(void)resetImageAndTitle{
    self.titreImg = @"";
    self.nbImages = 0;
}

@end
