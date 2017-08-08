//
//  OverPath.m
//  FotoMail
//
//  Created by Alistef on 07/08/2017.
//  Copyright © 2017 garfromDev. All rights reserved.
//

#import "OverPath.h"

@implementation OverPath

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.path = [[UIBezierPath alloc] init];
        self.rubber = false;
        self.drawColor = [UIColor redColor];
    }
    return self;
}

-(id _Nonnull) initWithPath: (UIBezierPath *_Nonnull)path drawColor: (UIColor *_Nonnull)color rubber: (BOOL)rubber
{
    self = [super init];
    if(self){
        self.path = path;
        self.drawColor = color;
        self.rubber = rubber;
    }
    return self;
}

@end
