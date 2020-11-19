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
    return listRecipients;
    }


- (void) setRecipients:(NSArray<NSString *> *)recipients{
    if(recipients == nil){
        // sécurité : si on reçoit nil, on remplace par unn tableau vide
        recipients = [[NSArray<NSString *> alloc ] init];
    }
    [[NSUserDefaults standardUserDefaults] setValue:recipients forKey:RECIPIENTS];
}


- (NSArray<NSString *> *)projects {
    NSArray *listProjects = [[ NSUserDefaults standardUserDefaults] arrayForKey:PROJECTS];
    return listProjects;
}


- (void) setProjects:(NSArray<NSString *> *)projects{
    // on élimine les chaines vides à la fin
    if([[projects lastObject] isEqualToString: @""]){
        projects = [projects subarrayWithRange:NSMakeRange(0, projects.count - 1)];
    }
    [[NSUserDefaults standardUserDefaults] setValue:projects forKey:PROJECTS];
    //si current project ne fait pas partie de project, il faut le mettre à chaine vide
    if([projects indexOfObject:[self currentPrjctWithoutSlash]] == NSNotFound){
        [self setCurrentProject:@""];
    }
}

/// usage interne, le projet courant tel que sauvé, sans le slash final
-(NSString *)currentPrjctWithoutSlash {
    return [[ NSUserDefaults standardUserDefaults] stringForKey:CURRENTPROJECT];
}


-(NSString *)currentProject {
    NSString *strCurrentProject = [self currentPrjctWithoutSlash];
    return [strCurrentProject stringByAppendingString:@"\\"];
}

-(void)setCurrentProject:(NSString *)currentProject{
    [[NSUserDefaults standardUserDefaults] setValue:currentProject forKey:CURRENTPROJECT];
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


-(NSArray<NSString *> *)recipientsWithExtension{
    NSMutableArray *rwe = [[NSMutableArray alloc] init];
    
    for( NSString *s in self.recipients ){
        NSString * withExt;
        NSArray<NSString *> *sub = [s componentsSeparatedByString:@"@"];
        
        if(sub.count == 2){ // une adresse e-mail valide doit contenir des choses avant et après le @
            withExt = sub[0];
            if(self.currentPrjctWithoutSlash.length){  //avoid +@ which is not accepeted by some mail provider
                withExt = [withExt stringByAppendingString:@"+"];
                withExt = [withExt stringByAppendingString:[self currentPrjctWithoutSlash]];
            }
            withExt = [withExt stringByAppendingString:@"@"];
            withExt = [withExt stringByAppendingString:sub[1]];
            [rwe addObject:withExt];
        }
    }
    return rwe;
}

@end
