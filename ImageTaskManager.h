//
//  ImageTaskManager.h
//  CQView
//
//  Created by Elliot on 2/7/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import <pthread.h>

@class IconFamily;
@class VitaminSEEController;

@interface ImageTaskManager : NSObject {
	// TASK QUEUE:
	pthread_mutex_t taskQueueLock;
	NSString* fileToDisplayPath;
	NSMutableArray* thumbnailQueue;
	NSMutableArray* preloadQueue;
	
	pthread_mutex_t imageCacheLock;
	NSMutableDictionary* imageCache;
	
	pthread_cond_t conditionLock;
	
	NSSize contentViewSize;
	float scaleRatio;
	BOOL scaleProportionally;
	int smoothing;
	pthread_mutex_t imageScalingProperties;
	
	NSImage* currentImage;
	int currentImageWidth;
	int currentImageHeight;
	float currentImageScale;
	
	NSImage* currentIconFamilyThumbnail;
	id currentIconCell;
	int thumbnailLoadingPosition;
	
	id vitaminSEEController;
	
	bool shouldBuildIcon;
}

-(id)initWithPortArray:(NSArray*)portArray;

-(void)preloadImage:(NSString*)path;
-(void)displayImageWithPath:(NSString*)path;
-(void)buildThumbnail:(NSString*)path forCell:(id)cell;
-(void)clearThumbnailQueue;

-(void)setShouldBuildIcon:(BOOL)newShouldBuildIcon;
-(void)setSmoothing:(int)newSmoothing;
-(void)setScaleRatio:(float)newScaleRatio;
-(void)setScaleProportionally:(BOOL)newScaleProportionally;
-(void)setContentViewSize:(NSSize)newContentViewSize;
-(void)setThumbnailLoadingPosition:(int)newPosition;

-(NSImage*)getCurrentImageWithWidth:(int*)width height:(int*)height scale:(float*)scale;
-(id)getCurrentThumbnailCell;
-(NSImage*)getCurrentThumbnail;

@end
