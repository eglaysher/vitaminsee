//
//  ImageTaskManager.h
//  CQView
//
//  Created by Elliot on 2/7/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import <pthread.h>



@interface ImageTaskManager : NSObject {
	pthread_mutex_t taskQueueLock;
	NSMutableArray* taskQueue;
	
	pthread_mutex_t imageCacheLock;
	NSMutableDictionary* imageCache;
	
	pthread_cond_t conditionLock;
	
	NSSize contentViewSize;
	float scaleRatio;
	BOOL scaleProportionally;
	pthread_mutex_t imageScalingProperties;
	
	NSImage* currentImage;
	int currentImageWidth;
	int currentImageHeight;
	
	id cqViewController;
}

-(id)initWithPortArray:(NSArray*)portArray;

-(NSImageRep*)getImage:(NSString*)path;
-(void)preloadImage:(NSString*)path;
-(void)displayImageWithPath:(NSString*)path;

-(void)setScaleRatio:(float)newScaleRatio;
-(void)setScaleProportionally:(BOOL)newScaleProportionally;
-(void)setContentViewSize:(NSSize)newContentViewSize;

-(NSImage*)getCurrentImageWithWidth:(int*)width height:(int*)height;

@end
