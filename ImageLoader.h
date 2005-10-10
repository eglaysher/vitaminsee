//
//  ImageLoader.h
//  Prototype
//
//  Created by Elliot Glaysher on 9/13/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#define SCALE_IMAGE_PROPORTIONALLY @"Scale Image Proportionally"
#define SCALE_IMAGE_TO_FIT         @"Scale Image to Fit"
#define SCALE_IMAGE_TO_FIT_WIDTH   @"Scale Image to Fit Width"
#define SCALE_IMAGE_TO_FIT_HEIGHT  @"Scale Image to Fit Height"


#define NO_SMOOTHING    @"No Smoothing"
#define LOW_SMOOTHING   @"Low Smoothing"
#define HIGH_SMOOTHING  @"High Smoothing"

@class EGPath;

@interface ImageLoader : NSObject {
}

+(void)loadTask:(NSMutableDictionary*)task;
+(void)preloadImage:(EGPath*)file;
@end
