/////////////////////////////////////////////////////////////////////////
// File:          $File$
// Module:        Loads and preloads images in a seperate thread and passes them
//                off to the main thread
// Part of:       VitaminSEE
//
// ID:            $Id: ImageTaskManager.m 123 2005-04-18 00:21:02Z elliot $
// Revision:      $Revision$
// Last edited:   $Date$
// Author:        $Author$
// Copyright:     (c) 2005 Elliot Glaysher
// Created:       2/7/05
//
/////////////////////////////////////////////////////////////////////////
//
// This library is free software; you can redistribute it and/or
// modify it under the terms of the GNU Lesser General Public
// License as published by the Free Software Foundation; either
// version 2.1 of the License, or (at your option) any later version.
//  
// This library is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
// Lesser General Public License for more details.
//  
// You should have received a copy of the GNU Lesser General Public
// License along with this library; if not, write to the Free Software
// Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  
// USA
//
/////////////////////////////////////////////////////////////////////////

#import "ImageTaskManager.h"
#import "Util.h"
#import "IconFamily.h"
#import "VitaminSEEController.h"
#import "NSString+FileTasks.h"

#define CACHE_SIZE 3

#define NO_SMOOTHING 1
#define LOW_SMOOTHING 2
#define HIGH_SMOOTHING 3

@interface ImageTaskManager (Private)
-(id)evictImages;
-(void)doPreloadImage:(NSString*)path;
-(void)doDisplayImage:(NSString*)imageToDisplay;
-(BOOL)newDisplayCommandInQueue;
-(void)sendDisplayCommandWithImage:(NSImage*)image width:(int)width height:(int)height;
@end

@implementation ImageTaskManager

// USE THESE DNS SERVERS!!!!!
// 141.213.4.4
// 141.213.4.5

-(id)initWithController:(id)parentController
{
	if(self = [super init])
	{
		pthread_mutex_init(&imageCacheLock, NULL);
		pthread_mutex_init(&taskQueueLock, NULL);
		pthread_cond_init(&conditionLock, NULL);
		
		imageCache = [[NSMutableDictionary alloc] init];
		preloadQueue = [[NSMutableArray alloc] init];

		// Now we start work on thread communication.
		NSPort *port1 = [NSPort port];
		NSPort *port2 = [NSPort port];
		NSConnection* kitConnection = [[NSConnection alloc] 
			initWithReceivePort:port1 sendPort:port2];
		[kitConnection setRootObject:parentController];
		
		NSArray *portArray = [NSArray arrayWithObjects:port2, port1, nil];		
		
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
	[preloadQueue release];
}

-(void)taskHandlerThread:(id)portArray
{
//	NSDictionary* currentTask;
	
	// Okay, first we get the distributed object VitaminSEEController up and running...
	NSAutoreleasePool *npool = [[NSAutoreleasePool alloc] init];
	NSConnection *serverConnection = [NSConnection
		connectionWithReceivePort:[portArray objectAtIndex:0]
						 sendPort:[portArray objectAtIndex:1]];
	
	vitaminSEEController = [serverConnection rootProxy];
	[vitaminSEEController setProtocolForProxy:@protocol(ImageDisplayer)];
	
	// Handle queue
	while(1)
	{
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		
		// Let's wait for stuff
		pthread_mutex_lock(&taskQueueLock);
		while(fileToDisplayPath == nil && [preloadQueue count] == 0)
		{
			if(pthread_cond_wait(&conditionLock, &taskQueueLock))
				NSLog(@"Invalid wait!?");
		}
		
		// Okay, taskQueueLock is locked. Let's try individual tasks.
		if(fileToDisplayPath != nil)
		{
			// Unlock the mutex
			NSString* path = [[fileToDisplayPath copy] autorelease];
			[fileToDisplayPath release];
			fileToDisplayPath = nil;
			pthread_mutex_unlock(&taskQueueLock);
			
			[self doDisplayImage:path];
		}
		else if([preloadQueue count])
		{
			NSString* path = [[preloadQueue objectAtIndex:0] retain];
			[preloadQueue removeObjectAtIndex:0];
			pthread_mutex_unlock(&taskQueueLock);
			
			[self doPreloadImage:path];
			[path release];
		}
		else
		{
			// Unlock the mutex
			pthread_mutex_unlock(&taskQueueLock);
		}

		[pool release];
	}
	
	[npool release];
}

-(void)setSmoothing:(int)newSmoothing
{
	pthread_mutex_lock(&imageScalingProperties);
	smoothing = newSmoothing;
	pthread_mutex_unlock(&imageScalingProperties);
}

-(void)setScaleRatio:(float)newScaleRatio
{
	pthread_mutex_lock(&imageScalingProperties);
	scaleRatio = newScaleRatio;
	pthread_mutex_unlock(&imageScalingProperties);
}

-(void)setScaleProportionally:(BOOL)newScaleProportionally
{
	pthread_mutex_lock(&imageScalingProperties);
	scaleProportionally = newScaleProportionally;
	pthread_mutex_unlock(&imageScalingProperties);
}

-(void)setContentViewSize:(NSSize)newContentViewSize
{
	pthread_mutex_lock(&imageScalingProperties);
	contentViewSize = newContentViewSize;
	pthread_mutex_unlock(&imageScalingProperties);	
}

-(void)displayImageWithPath:(NSString*)path
{
	pthread_mutex_lock(&taskQueueLock);
	
	// Make this the NEXT thing we do.
	[fileToDisplayPath release];
	[path retain];
	fileToDisplayPath = path;
	
	// Note that we are OUT of here...
	pthread_cond_signal(&conditionLock);
	pthread_mutex_unlock(&taskQueueLock);
}

-(void)preloadImage:(NSString*)path
{	
	pthread_mutex_lock(&taskQueueLock);

	while([preloadQueue count] > CACHE_SIZE)
		[preloadQueue removeObjectAtIndex:0];
	
	// Add the object
	if(![[[path pathExtension] uppercaseString] isEqual:@"ICNS"])
		[preloadQueue addObject:path];
	
	// Note that we are OUT of here...
	pthread_cond_signal(&conditionLock);
	pthread_mutex_unlock(&taskQueueLock);
}

-(NSImage*)getCurrentImageWithWidth:(int*)width height:(int*)height scale:(float*)scale
{
	if(width)
		*width = currentImageWidth;
	if(height)
		*height = currentImageHeight;
	if(scale)
		*scale = currentImageScale;
	
	return currentImage;
}

@end

@implementation ImageTaskManager (Private)

-(id)evictImages
{
	// ASSUMPTION: imageCacheLock is ALREADY locked!
	if([imageCache count] > CACHE_SIZE)
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
//		NSImageRep* rep = [NSImageRep imageRepWithContentsOfFile:path];
		NSImageRep* rep = loadImage(path);
		NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:
			[NSDate date], @"Date", rep, @"Image", nil];

		pthread_mutex_lock(&imageCacheLock);
		[self evictImages];
		[imageCache setObject:dict forKey:path];
	}
	pthread_mutex_unlock(&imageCacheLock);	
}

-(void)doDisplayImage:(NSString*)path
{
	// Before we aquire our internal lock, tell the main application to start
	// spinning...
	[vitaminSEEController startProgressIndicator];
	if([path isDir])
	{
		// We are working with a directory.
		NSImage* image = [[NSWorkspace sharedWorkspace] iconForFile:path];
		[image setSize:NSMakeSize(128, 128)];
			
		[image retain];
		[self sendDisplayCommandWithImage:image width:128 height:128];
		[image release];
			
		// An image has been displayed so stop the spinner
		[vitaminSEEController stopProgressIndicator];	
		return;
	}
	else if([[[path pathExtension] uppercaseString] isEqual:@"ICNS"])		
	{
		NSImage* image = [[NSImage alloc] initWithContentsOfFile:path];
		NSSize size = [image size];
		
		[self sendDisplayCommandWithImage:image width:size.width height:size.height];
		[image release];
		
		// Stop the spinner
		[vitaminSEEController stopProgressIndicator];
		
		return;
	}

	NSImageRep* imageRep;
	pthread_mutex_lock(&imageCacheLock);
	NSDictionary* cacheEntry = [imageCache objectForKey:path];
	
	// If the image isn't in the cache...
	if(!cacheEntry)
	{
		pthread_mutex_unlock(&imageCacheLock);

//		NSLog(@"Loading file '%@'", path);
		// Load the file, since it obviously hasn't been loaded.
		imageRep = loadImage(path);
//		[NSImageRep imageRepWithData:[NSData dataWithContentsOfFile:path]];
		cacheEntry = [NSDictionary dictionaryWithObjectsAndKeys:
			[NSDate date], @"Date", imageRep, @"Image", nil];
		
		pthread_mutex_lock(&imageCacheLock);
		// Evict an old cache entry
		[self evictImages];
		
		// Add the image to the cache so subsquent hits won't require reloading...
		[imageCache setObject:cacheEntry forKey:path];
	}
//	else
//		NSLog(@"Using cached version of '%@'", path);
	
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
									   &canGetAwayWithQuickRender, &currentImageScale);
	
//	NSLog(@"Image:[%d, %d] Dispaly:[%d, %d]", imageX, imageY, display.width, display.height);
	
	NSImage* imageToRet;
	if(smoothing == NO_SMOOTHING || imageRepIsAnimated(imageRep))
	{
		// Draw the image by just making an NSImage from the imageRep. This is
		// done when the image will have no smoothing, or when we are 
		// rendering an animated GIF.
		imageToRet = [[[NSImage alloc] init] autorelease];
		[imageToRet addRepresentation:imageRep];
		
		// Scale it anyway, because some pictures LIE about their size.
		[imageToRet setScalesWhenResized:YES];
		[imageToRet setSize:NSMakeSize(display.width, display.height)];
		
		[imageToRet retain];
		[self sendDisplayCommandWithImage:imageToRet width:imageX height:imageY];
		[imageToRet release];
	}
	else
	{
		// First, we draw the image with no interpolation, and send that representation
		// to the screen for SPEED so it LOOKS like we are doing something.
		imageToRet = [[[NSImage alloc] initWithSize:NSMakeSize(display.width,
			display.height)] autorelease];
		
		// This block could throw on a bad file. We catch and error
		@try
		{
			[imageToRet lockFocus];
			{
				[[NSGraphicsContext currentContext] 
					setImageInterpolation:NSImageInterpolationNone];
				[imageRep drawInRect:NSMakeRect(0,0,display.width,display.height)];
			}
			[imageToRet unlockFocus];		
		}
		@catch(NSException* e)
		{
			// The image will still be locked, even if -lock fails.
			[imageToRet unlockFocus];

			// Alert the user to a problem
			NSString* format = NSLocalizedString(@"Can not display %@", 
				@"Error message: 'Can not display FILENAME'");
			NSString* informativeText = NSLocalizedString(@"Please chcek that it's a valid file",
				@"Localized informative text on can't load image error");
			
			[vitaminSEEController displayAlert:[NSString stringWithFormat:
				format, [path lastPathComponent]]
							   informativeText:informativeText
									helpAnchor:@"IMAGE_WONT_LOAD_ANCHOR"];
			[vitaminSEEController stopProgressIndicator];
			return;
		}
		
		[self sendDisplayCommandWithImage:imageToRet width:imageX height:imageY];
		
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
			switch(smoothing)
			{
				case LOW_SMOOTHING:
					[[NSGraphicsContext currentContext] 
						setImageInterpolation:NSImageInterpolationLow];
					break;
				default:
				case HIGH_SMOOTHING:
					[[NSGraphicsContext currentContext] 
						setImageInterpolation:NSImageInterpolationHigh];
			}

			[imageRep drawInRect:NSMakeRect(0,0,display.width,display.height)];
		}
		[imageToRet unlockFocus];
		
		// Now display the final image:
		[self sendDisplayCommandWithImage:imageToRet width:imageX height:imageY];
	}
	
	// An image has been displayed so stop the spinner
	[vitaminSEEController stopProgressIndicator];	
}

-(BOOL)newDisplayCommandInQueue
{
	BOOL retVal = NO;
	pthread_mutex_lock(&taskQueueLock);
	retVal = fileToDisplayPath != nil;
	pthread_mutex_unlock(&taskQueueLock);
	return retVal;
}

-(void)sendDisplayCommandWithImage:(NSImage*)image width:(int)width height:(int)height
{
	[currentImage release];
	[image retain];
	currentImage = image;
	
	currentImageWidth = width;
	currentImageHeight = height;
	
	[vitaminSEEController displayImage];
}

@end