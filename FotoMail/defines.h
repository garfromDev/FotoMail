//
//  defines.h
//  FotoMail
//
//  Created by Alistef on 25/08/2016.
//  Copyright © 2016 garfromDev. All rights reserved.
//

#ifndef defines_h
#define defines_h

#define LOG NSLog(@"%@",NSStringFromSelector(_cmd));
// identifier for NSUSerDefaults
#define TIMESTAMP @"timeStamp"
#define STAMPSIZE @"stampSize"
#define PREVIEW @"preview"
#define RECIPIENTS @"recipients"
#define PROJECTS @"projects"
#define NBIMAGE @"nbImage"
#define IMGNUMBER @"imgNumber"

// predefined size for timestamp
#define SMALL 48.0f
#define MEDIUM 96.0f
#define LARGE 160.0f

//predefined line thickness for edition
#define DEFAULT_THICKNESS 30.0

//predefined rubber thickness for edition
#define DEFAULT_RUBBER_THICKNESS 90.0

//corner radius of icons in setting
#define CORNER_RADIUS 7.0

// sound when capturing picture
#define PHOTO_SOUND 1108

// default time for animations
#define ANIMATION_TIME 0.2

// default scale to apply when long pressing an item
#define LONGPRESS_SCALE 1.6

//mode screenshot for capturing AppSTore screenshot on simulator
// comment out for device/release
//#define SCREENSHOTMODE

#ifdef SCREENSHOTMODE
#pragma message "!!!!! SCREENSHOT MODE FOR SIMULATOR USE !!!!!"
#endif

//size for dummy green picture when screenshot mode is used
#define DUMMYWIDTH 600
#define DUMMYHEIGHT 400

#endif /* defines_h */
