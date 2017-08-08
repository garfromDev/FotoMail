//
//  PathMixer.h
//  FotoMail
//
//  Created by Alistef on 07/08/2017.
//  Copyright © 2017 garfromDev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "OverPath.h"


@protocol PathMixerprotocol
+ (void) saveEditedWithImage: (UIImage *)originaleImg paths: (NSArray<OverPath *> *)paths completion:(void(^)(UIImage *finalImg)) completion;
@end

/// le pathMixer fourni une image composite à partir des Overpaths et de l'image originale
@interface PathMixer : NSObject<PathMixerprotocol>
+ (void) saveEditedWithImage: (UIImage *)originaleImg paths: (NSArray<OverPath *> *)paths completion:(void(^)(UIImage *finalImg)) completion;
@end
