//
//  ImageTaskManager.m
//  CQView
//
//  Created by Elliot on 2/7/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "ImageTaskManager.h"
#import "Util.h"
#import "IconFamily.h"
#import "CQViewController.h"

@interface ImageTaskManager (Private)
-(id)evictImages;
-(void)doPreloadImage:(NSString*)path;
-(void)doDisplayImage:(NSString*)imageToDisplay;
-(BOOL)newDisplayCommandInQueue;
-(void)sendDisplayCommandWithImage:(NSImage*)image;
@end

// This category is here because Distributed Objects are TOTALLY BRAIN DEAD.
// See; Problems with Distributed Objects by Andreas Mayer on the Cocoadev ML.
@implementation NSImage (FixBraindeadCoder)
-(id)replacementObjectForPortCoder:(NSPortCoder*)encoder
{
	// We are returning bycopy whether we like it or not.
	return self;
//	if([encoder isBycopy])
//	{
//		NSLog(@"Woot! Bycopy!");
//		return self;
//	}
//	NSLog(@"Huh!? not bycopy!?");
//	return [super replacementObjectForProtCoder:encoder];
}
@end

@implementation ImageTaskManager

-(id)initWithPortArray:(NSArray*)portArray
{
	if(self = [super init])
	{
		pthread_mutex_init(&imageCacheLock, NULL);
		pthread_mutex_init(&taskQueueLock, NULL);
		pthread_cond_init(&conditionLock, NULL);
		
		imageCache = [[NSMutableDictionary alloc] init];
		taskQueue = [[NSMutableArray alloc] init];
		
		// spawn off a new thread
		[NSThread detachNewThreadSelector:@selector(taskHandlerThread:) 
								 toTarget:self
							   withObject:portArray];
	}
	return self;
}

-(void)dealloc
{
	// shut down taskHandlerThread...
	
	// destroy our mutexes!
	pthread_mutex_destroy(&imageCacheLock);
	pthread_mutex_destroy(&taskQueueLock);
	pthread_cond_destroy(&conditionLock);
	
	// destroy our mutexed data!
	[imageCache release];
	[taskQueue release];
}

-(void)taskHandlerThread:(id)portArray
{
	NSDictionary* currentTask;
	
	// Okay, first we get the distributed object CQViewController up and running...
	NSAutoreleasePool *npool = [[NSAutoreleasePool alloc] init];
	NSConnection *serverConnection = [NSConnection
		connectionWithReceivePort:[portArray objectAtIndex:0]
						 sendPort:[portArray objectAtIndex:1]];
	
	cqViewController = [serverConnection rootProxy];
	[cqViewController setProtocolForProxy:@protocol(ImageDisplayer)];
	
	// Handle queue
	while(1)
	{
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		
		// Let's wait for stuff
		pthread_mutex_lock(&taskQueueLock);
		while([taskQueue count] == 0)
		{
			if(pthread_cond_wait(&conditionLock, &taskQueueLock))
				NSLog(@"Invalid wait!?");
		}

		// Get a task out of our task queue...
		currentTask = [[taskQueue objectAtIndex:0] retain];
		[taskQueue removeObjectAtIndex:0];

		// what kind of task is this?
		NSString* type = [currentTask objectForKey:@"Type"];
		NSString* path = [currentTask objectForKey:@"Path"];
		pthread_mutex_unlock(&taskQueueLock);
		
		if([type isEqual:@"BuildIcon"])
		{
			// Build an icon for this file.
			NSImage* image = [[[NSImage alloc] initWithContentsOfFile:path] autorelease];
			IconFamily* iconFamily = [IconFamily iconFamilyWithThumbnailsOfImage:image];
			[iconFamily setAsCustomIconForFile:path];
			
			// We need some kind of way to tell if this completed!
		}
		else if([type isEqual:@"PreloadImage"])
		{
			[self doPreloadImage:path];
			// Load the ImageRep into the
			// [self evictOldImage];
		}
		else if([type isEqual:@"DisplayImage"])
		{
//			[cqViewController displayImage:nil];
			[self doDisplayImage:path];
		}
		else
			NSLog(@"WARNING! I don't know how to do task type '%@'", type);

		[currentTask release];
		[pool release];
	}
}


-(void)setScaleRatio:(float)newScaleRatio
{
	pthread_mutex_lock(&imageScalingProperties);
	scaleRatio = newScaleRatio;
	pthread_mutex_unlock(&imageScalingProperties);
	NSLog(@"Our scale ratio %f, come in %f", scaleRatio, newScaleRatio);
}

-(void)setScaleProportionally:(BOOL)newScaleProportionally
{
	pthread_mutex_lock(&imageScalingProperties);
	scaleProportionally = newScaleProportionally;
	pthread_mutex_unlock(&imageScalingProperties);
	NSLog(@"Our scale prop %d, come in %d", scaleProportionally, newScaleProportionally);
}

-(void)setContentViewSize:(NSSize)newContentViewSize
{
	pthread_mutex_lock(&imageScalingProperties);
	contentViewSize = newContentViewSize;
	pthread_mutex_unlock(&imageScalingProperties);	
	NSLog(@"[%f, %f]", contentViewSize.width, contentViewSize.height);
}

-(void)displayImageWithPath:(NSString*)path
{
	NSDictionary* currentTask = [NSDictionary dictionaryWithObjectsAndKeys:
		@"DisplayImage", @"Type", path, @"Path", nil];
	
	pthread_mutex_lock(&taskQueueLock);
	// First we go through the task queue and remove other DisplayImage tasks
	int i;
	for(i = [taskQueue count] - 1; i > -1; i--)
		if([[[taskQueue objectAtIndex:i] objectForKey:@"Type"] isEqualTo:@"DisplayImage"])
		{
			NSLog(@"Removing old display task...");
			[taskQueue removeObjectAtIndex:i];
		}
	
	// Make this the NEXT thing we do.
	[taskQueue insertObject:currentTask atIndex:0];
	
	// Note that we are OUT of here...
	pthread_cond_signal(&conditionLock);
	pthread_mutex_unlock(&taskQueueLock);
}

-(void)preloadImage:(NSString*)path
{	
	NSDictionary* currentTask = [NSDictionary dictionaryWithObjectsAndKeys:
		@"PreloadImage", @"Type", path, @"Path", nil];

	pthread_mutex_lock(&taskQueueLock);
	NSLog(@"Going to preload: %@", path);
	// Add the object
	[taskQueue addObject:currentTask];
	
	// Note that we are OUT of here...
	pthread_cond_signal(&conditionLock);
	pthread_mutex_unlock(&taskQueueLock);
}

-(NSImageRep*)getImage:(NSString*)path
{
	// First we check to see if there is a task to preload path. If there is,
	// delete it.
//	pthread_mutex_lock(&taskQueueLock);
//	int i;
//	for(i = [taskQueue count] - 1; i > -1; i--)
//		if([[[taskQueue objectAtIndex:i] objectForKey:@"Path"] isEqualTo:path])
//		{
//			NSLog(@"Removing old task for %@", path);
//			[taskQueue removeObjectAtIndex:i];
//		}				
//	pthread_mutex_unlock(&taskQueueLock);
	
	NSImageRep* imageRep;
	pthread_mutex_lock(&imageCacheLock);
	NSDictionary* cacheEntry = [imageCache objectForKey:path];
	
	// If the image isn't in the cache...
	if(!cacheEntry)
	{
		pthread_mutex_unlock(&imageCacheLock);
		NSLog(@"'%@' isn't in the cache. Loading...", path);
		// Load the file, since it obviously hasn't been loaded.
		imageRep = [NSImageRep imageRepWithContentsOfFile:path];
		cacheEntry = [NSDictionary dictionaryWithObjectsAndKeys:
			[NSDate date], @"Date", imageRep, @"Image", nil];
		
		pthread_mutex_lock(&imageCacheLock);
		// Evict an old cache entry
		[self evictImages];
		
		// Add the image to the cache so subsquent hits won't require reloading...
		[imageCache setObject:cacheEntry forKey:path];
	}
	else
		NSLog(@"Using cached version of '%@'", path);
	
	imageRep = [cacheEntry objectForKey:@"Image"];
	
	// Unlock so braindeadness doesn't occur.
	pthread_mutex_unlock(&imageCacheLock);
	return imageRep;
}

@end

@implementation ImageTaskManager (Private)

-(id)evictImages
{
	// ASSUMPTION: imageCacheLock is ALREADY locked!
	if([imageCache count] > 3)
	{
		NSString* oldestPath = nil;
		NSDate* oldestDate = [NSDate date]; // set oldest as now, so anything older
		
		NSEnumerator* e = [imageCache keyEnumerator];
		NSString* cur;
		while(cur = [e nextObject]) 
		{
			NSDictionary* cacheEntry = [imageCache objectForKey:cur];
			if([oldestDate compare:[cacheEntry objectForKey:@"Date"]] == NSOrderedDescending)
			{
				// this is older!
				oldestDate = [cacheEntry objectForKey:@"Date"];
				oldestPath = cur;
			}
		}
		
		// Let's get rid of the oldest path...
		[imageCache removeObjectForKey:oldestPath];
	}
}

-(void)doPreloadImage:(NSString*)path
{
	pthread_mutex_lock(&imageCacheLock);
	// If the image hasn't already been loaded into the cache...
	if(![imageCache objectForKey:path])
	{
		pthread_mutex_unlock(&imageCacheLock);
		// Preload the image
		NSImageRep* rep = [NSImageRep imageRepWithContentsOfFile:path];
		NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:
			[NSDate date], @"Date", rep, @"Image", nil];

		pthread_mutex_lock(&imageCacheLock);
		[self evictImages];
		[imageCache setObject:dict forKey:path];
	}
	pthread_mutex_unlock(&imageCacheLock);	
}

-(NSImage*)getCurrentImage
{
	return currentImage;
}

-(void)doDisplayImage:(NSString*)path
{
	// Now we lock the image queue and see if we have a new file

	// Okay! Now we have to
	
	NSImageRep* imageRep;
	pthread_mutex_lock(&imageCacheLock);
	NSDictionary* cacheEntry = [imageCache objectForKey:path];

	// If the image isn't in the cache...
	if(!cacheEntry)
	{
		pthread_mutex_unlock(&imageCacheLock);
				
		// Load the file, since it obviously hasn't been loaded.
		imageRep = [NSImageRep imageRepWithContentsOfFile:path];
		cacheEntry = [NSDictionary dictionaryWithObjectsAndKeys:
			[NSDate date], @"Date", imageRep, @"Image", nil];
		
		pthread_mutex_lock(&imageCacheLock);
		// Evict an old cache entry
		[self evictImages];
		
		// Add the image to the cache so subsquent hits won't require reloading...
		[imageCache setObject:cacheEntry forKey:path];
	}
	else
		NSLog(@"Using cached version of '%@'", path);
	
	imageRep = [cacheEntry objectForKey:@"Image"];
	
	// Unlock the image cache. We don't need it anymore...
	pthread_mutex_unlock(&imageCacheLock);	

	// Check to see if we should go on. Has someone made a different request
	// in the time where we've been loading the image?
	if([self newDisplayCommandInQueue])
		return;
	
	// Now we start with the resizing procedure

	// We need to lock during the reading of the following properties...
	NSSize sizeOfDisplayBox;
	BOOL canScaleProportionally;
	float ratioToScale;
	pthread_mutex_lock(&imageScalingProperties);
	sizeOfDisplayBox = contentViewSize;
	canScaleProportionally = scaleProportionally;
	ratioToScale = scaleRatio;
	pthread_mutex_unlock(&imageScalingProperties);

	int imageX = [imageRep pixelsWide];
	int imageY = [imageRep pixelsHigh];
	int displayBoxWidth = sizeOfDisplayBox.width;
	int displayBoxHeight = sizeOfDisplayBox.height;
	
//	NSSize buildImageSize(int boxWidth, int boxHeight, int imageWidth, int imageHeight,
//						  BOOL canScaleProportionally, float ratioToScale,
//						  BOOL*canGetAwayWithQuickRender);
	BOOL canGetAwayWithQuickRender;	
	struct DS display = buildImageSize(displayBoxWidth, displayBoxHeight, imageX, 
									   imageY, canScaleProportionally, ratioToScale,
									   &canGetAwayWithQuickRender);
	
	NSLog(@"DispalyX: %d, DisplayY: %d", display.width, display.height);
	
	NSImage* imageToRet;
	if(imageRepIsAnimated(imageRep) || canGetAwayWithQuickRender)
	{
		// Draw the image by just making an NSImage from the imageRep. This is
		// done when the image will fit in the viewport, or when we are 
		// rendering an animated GIF.
		imageToRet = [[[NSImage alloc] init] autorelease];
		[imageToRet addRepresentation:imageRep];
		
		// Scale it anyway, because some pictures LIE about their size.
		[imageToRet setScalesWhenResized:YES];
		[imageToRet setSize:NSMakeSize(display.width, display.height)];
		
		[imageToRet retain];
		[self sendDisplayCommandWithImage:imageToRet];
		[imageToRet release];
	}
	else
	{
		// First, we draw the image with no interpolation, and send that representation
		// to the screen for SPEED so it LOOKS like we are doing something.
		imageToRet = [[[NSImage alloc] initWithSize:NSMakeSize(display.width,
			display.height)] autorelease];
		[imageToRet lockFocus];
		{
			[[NSGraphicsContext currentContext] 
				setImageInterpolation:NSImageInterpolationNone];
			[imageRep drawInRect:NSMakeRect(0,0,display.width,display.height)];
		}
		[imageToRet unlockFocus];		
		[self sendDisplayCommandWithImage:imageToRet];
		
		// Now give us a chance to BAIL if we've already been given another display
		// command
		if([self newDisplayCommandInQueue])
			return;
		
		// Draw the image onto a new NSImage using smooth scaling. This is done
		// whenever the image isn't animated so that the picture will have 
		// some antialiasin lovin' applied to it.
		imageToRet = [[[NSImage alloc] initWithSize:NSMakeSize(display.width,
			display.height)] autorelease];
		[imageToRet lockFocus];
		{
			[[NSGraphicsContext currentContext] 
				setImageInterpolation:NSImageInterpolationHigh];
			[imageRep drawInRect:NSMakeRect(0,0,display.width,display.height)];
		}
		[imageToRet unlockFocus];
		
		// Now display the final image:
		[self sendDisplayCommandWithImage:imageToRet];
	}	
}

-(BOOL)newDisplayCommandInQueue
{
	BOOL retVal = NO;
	pthread_mutex_lock(&taskQueueLock);

	NSEnumerator* e = [taskQueue objectEnumerator];
	NSDictionary* dict;
	while(dict = [e nextObject])
		if([[dict objectForKey:@"Type"] isEqual:@"DisplayImage"])
		{
			retVal = YES;
			break;
		}
	
	pthread_mutex_unlock(&taskQueueLock);
	return retVal;
}

-(void)sendDisplayCommandWithImage:(NSImage*)image
{
	[currentImage release];
	[image retain];
	currentImage = image;
	[cqViewController displayImage];
}

@end