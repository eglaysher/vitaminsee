//
//  ImageLoader.h
//  Prototype
//
//  Created by Elliot Glaysher on 9/13/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

extern NSString* SCALE_IMAGE_PROPORTIONALLY;
extern NSString* SCALE_IMAGE_TO_FIT;
extern NSString* SCALE_IMAGE_TO_FIT_WIDTH;
extern NSString* SCALE_IMAGE_TO_FIT_HEIGHT;

extern NSString* NO_SMOOTHING;
extern NSString* LOW_SMOOTHING;
extern NSString* HIGH_SMOOTHING;

@class EGPath;

@interface ImageLoader : NSObject {
}

+(void)loadTask:(NSMutableDictionary*)task;
+(void)preloadImage:(EGPath*)file;
@end
