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
}

-(NSImageRep*)getImage:(NSString*)path;
-(void)preloadImage:(NSString*)path;

@end
