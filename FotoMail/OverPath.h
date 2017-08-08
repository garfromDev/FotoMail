//
//  OverPath.h
//  FotoMail
//
//  Created by Alistef on 07/08/2017.
//  Copyright © 2017 garfromDev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/// Déclaration d'un type regroupant le path, sa couleur et son mode
/// utilisé par Pathmanager, PathProvider et PathMixer
@interface OverPath : NSObject

@property(strong, nonatomic, nonnull) UIBezierPath *path;
@property(strong, nonatomic, nonnull) UIColor *drawColor;
@property BOOL rubber;
/// convenience, le path sera initialisé en UIBeizerPath vierge
-(id _Nonnull) initWithPath: (UIBezierPath *_Nonnull)path drawColor: (UIColor *_Nonnull)color rubber: (BOOL)rubber;

@end

