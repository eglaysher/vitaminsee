/////////////////////////////////////////////////////////////////////////
// File:          $URL$
// Module:        Loads images in a seperate thread.
// Part of:       VitaminSEE
//
// ID:            $Id: ApplicationController.m 123 2005-04-18 00:21:02Z elliot $
// Revision:      $Revision$
// Last edited:   $Date$
// Author:        $Author$
// Copyright:     (c) 2005 Elliot Glaysher
// Created:       9/13/05
//
/////////////////////////////////////////////////////////////////////////
//
// This program is free software; you can redistribute it and/or
// modify it under the terms of the GNU General Public License
// as published by the Free Software Foundation; either version 2
// of the License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program; if not, write to the Free Software
// Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
//
////////////////////////////////////////////////////////////////////////

#import "ImageLoader.h"
#import "EGPath.h"
#import "pthread.h"
#import "Util.h"
#import "ViewerDocument.h"
#import "NSString+FileTasks.h"

#define CACHE_SIZE 3

// Externed constants
NSString* SCALE_IMAGE_PROPORTIONALLY = @"Scale Image Proportionally";
NSString* SCALE_IMAGE_TO_FIT         = @"Scale Image to Fit";
NSString* SCALE_IMAGE_TO_FIT_WIDTH   = @"Scale Image to Fit Width";
NSString* SCALE_IMAGE_TO_FIT_HEIGHT  = @"Scale Image to Fit Height";

NSString* NO_SMOOTHING               = @"No Smoothing";
NSString* LOW_SMOOTHING              = @"Low Smoothing";
NSString* HIGH_SMOOTHING             = @"High Smoothing";


// No data structures can be written to when the taskQueueLock is locked.
static pthread_mutex_t taskQueueLock;
static pthread_cond_t conditionLock;

// Map of requester to handle. Each request has the following form:
// 'requester id' => {
//  	@"Requester" => id,
//  	@"Path" => EGPath*,
//      @"Scale Mode" => NSString,
//      @"Viewing Area Height" => NSNumber,
//      @"Viewing Area Width" => NSNumber
//      @"Smoothing" => NSNumber // based on smoothing tag 
// }	
static NSMutableDictionary* taskQueue;
	
// Array of the next images to preload... [EGPath, EGPath...]
static NSMutableArray* preloadQueue = 0;

static NSMutableDictionary* imageCache = 0;

/** Describes a set of functions used to check if a certain task should be 
 * canceled our not.
 * 
 * We use a function pointer instead of a selector both because of speed 
 * issues...and because there's no performSelector: on Class objects.
 *
 * @see newTaskForSameRequester, newTaskThatPreemptsPreload
 */
typedef BOOL (*CANCELCHECK)(NSDictionary*);

/** Callback function used by methods that ask for a function pointer of 
 * CANCELCHECK. This function checks to see if the requester who has requested
 * the image currently being worked with has requested another (different?)
 * picture.
 *
 * @param currentTask Task Dictionary containing current task.
 * @return Whether the loading of the currentTask should be canceled.
 * @see CANCELCHECK
 */
static BOOL newTaskForSameRequester(NSDictionary* currentTask)
{
	id obj;
	id req = [currentTask objectForKey:@"Requester"];
		//(id)CFDictionaryGetValue((CFDictionaryRef)currentTask, @"Requester");
	NSNumber* num = [req documentID];
	pthread_mutex_lock(&taskQueueLock);
	{
		obj = [taskQueue objectForKey:num];
			//(id)CFDictionaryGetValue((CFDictionaryRef)taskQueue, num);
	}
	pthread_mutex_unlock(&taskQueueLock);
	
	return obj != nil;
}

//-----------------------------------------------------------------------------

/** Callback funcction used by methods that ask for a function pointer of
 * CANCELCHECK. This function checks to see if for the preloading task 
 * represented by currentTask should be canceled. Preloading tasks are canceled
 * when an image load request has been issued for a file that ISN'T the file
 * currently being preloaded.
 *
 * @param currentTask Task Dictionary containing current preload task.
 * @return Whether the loading of the currentTask should be canceled.
 * @see CANCELCHECK
 */
static BOOL newTaskThatPreemptsPreload(NSDictionary* currentTask)
{
	BOOL cancel = NO;
	pthread_mutex_lock(&taskQueueLock);
	{
		int count = [taskQueue count];
		if([taskQueue count]) {
			cancel = YES;
			
			EGPath* path = [currentTask objectForKey:@"Path"];
			NSArray* keys = [taskQueue allKeys];
			
			// Walk through the paths being requested one by one. If one of them
			// is the same as the path currently being loaded in currentTask, 
			// then 
			int i;
			for(i = 0; i < count; ++i) {
				// Working on making this the correct expression
				NSDictionary* dic = [taskQueue objectForKey:[keys objectAtIndex:i]]; 
				EGPath* thisPath = [dic objectForKey:@"Path"];
				if([path isEqual:thisPath]) {
//					NSLog(@"Continuing with preload because a display command needs it.");
					cancel = NO;
					break;
				}
			}
		}
	}
	pthread_mutex_unlock(&taskQueueLock);
	
	return cancel;
}

@interface ImageLoader (Private)
+(void)doDisplayImage:(NSMutableDictionary*)task;
+(NSImageRep*)loadImageForTask:(NSMutableDictionary*)task 
				cancelFunction:(CANCELCHECK)cancelFunction;
+(NSSize)calculateTargetImageSize:(NSMutableDictionary*)task 
						 imageRep:(NSImageRep*)imageRep;
+(void)evictImages;
+(void)doPreloadImage:(EGPath*)path;
@end

@implementation ImageLoader

/** Class initializer. Creates mutexes and class variables. Spawns thread 
 * handeling thread. 
 */
+(void)initialize
{
	// Create the main data structures
	pthread_mutex_init(&taskQueueLock, NULL);
	pthread_cond_init(&conditionLock, NULL);
	taskQueue = [[NSMutableDictionary alloc] init];
	preloadQueue = [[NSMutableArray alloc] init];
	imageCache = [[NSMutableDictionary alloc] init];
	
	// Spawn child thread here.
	[NSThread detachNewThreadSelector:@selector(taskHandlerThread:)
							 toTarget:[ImageLoader class]
						   withObject:nil];
}

//-----------------------------------------------------------------------------

/** Function called by user which loads an image. This function sets the passed
 * in task as the current image to load for the object that called this 
 * function.
 *
 * @param task Task Dictionary that 
 */
+(void)loadTask:(NSMutableDictionary*)task
{	
	id requester = [task objectForKey:@"Requester"];
	NSNumber* num = [requester documentID];
	pthread_mutex_lock(&taskQueueLock);
	{	
		// Record the document id in the task dictionary
		[task setObject:num forKey:@"Requester ID"];
		
		// set this as the current request for the requesting object.
		[taskQueue setObject:task forKey:num];
			
		// Inform the thread that there's something new to do.
		pthread_cond_signal(&conditionLock);
	}
	pthread_mutex_unlock(&taskQueueLock);
}

//-----------------------------------------------------------------------------

/** Function called by user which preloads an image into memory. This function
 * will simply add the path of the file into a FIFO queue (which pops from the
 * front when there's more then CACHED_IMAGE images.)
 *
 * @param file EGPath to the file to load
 */
+(void)preloadImage:(EGPath*)file
{
	pthread_mutex_lock(&taskQueueLock);
	{
		[preloadQueue addObject:file];

		// Inform the thread that there's something new to do.
		pthread_cond_signal(&conditionLock);
	}
	pthread_mutex_unlock(&taskQueueLock);
}


//-----------------------------------------------------------------------------

/** Remove a possible pending load operation.
 */
+(void)unregisterRequester:(id)requester
{
	NSNumber* num = [requester documentID];
	pthread_mutex_lock(&taskQueueLock);
	{
		// Remove any pending loads for this object
		[taskQueue removeObjectForKey:num];
		
		// Remove any pending calls to this object
		[NSObject cancelPreviousPerformRequestsWithTarget:requester];
	}
	pthread_mutex_unlock(&taskQueueLock);
}

@end

// ----------------------------------------------------------------------------

@implementation ImageLoader (Private)

/** Main function for the task handler thread. Handles loading and preloading
* reuqests and passes the data back to the main thread.
*
* @param nilObject Object placeholder since 
*                  +detachNewThreadSelector:toTarget:withObject: requires passing
*                  an object.
*/
+(void)taskHandlerThread:(id)nilObject
{
	NSAutoreleasePool *npool = [[NSAutoreleasePool alloc] init];
	
	// We are the most important thread in the program
	[NSThread setThreadPriority:0.5];
	
	// Handle queue
	while(1)
	{
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		
		// Let's wait for stuff
		pthread_mutex_lock(&taskQueueLock);
		int taskQueueCount = CFDictionaryGetCount((CFDictionaryRef)taskQueue);
		int preloadQueueCount = CFArrayGetCount((CFArrayRef)preloadQueue);
		
		while(taskQueueCount == 0 && preloadQueueCount == 0)
		{
			if(pthread_cond_wait(&conditionLock, &taskQueueLock))
				NSLog(@"Invalid wait!?");
			
			taskQueueCount = CFDictionaryGetCount((CFDictionaryRef)taskQueue);
			preloadQueueCount = CFArrayGetCount((CFArrayRef)preloadQueue);
		}

		// Okay, taskQueueLock is locked. Let's try individual tasks.
		if(taskQueueCount)
		{
			// Check the requester at the front of 
			id firstRequester = (id)CFArrayGetValueAtIndex(
				(CFArrayRef)[taskQueue allKeys], 0);
			NSMutableDictionary* currentTask = (id)CFDictionaryGetValue(
				(CFDictionaryRef)taskQueue, firstRequester);
			[currentTask retain];
			[taskQueue removeObjectForKey:firstRequester];
		
			pthread_mutex_unlock(&taskQueueLock);

			if(currentTask)
				[self doDisplayImage:currentTask];
		}
		else if(preloadQueueCount)
		{
			while([preloadQueue count] > CACHE_SIZE)
				[preloadQueue removeObjectAtIndex:0];
			
			EGPath* path = [[preloadQueue objectAtIndex:0] retain];
			[preloadQueue removeObjectAtIndex:0];
			pthread_mutex_unlock(&taskQueueLock);
			
			if(path)
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

//-----------------------------------------------------------------------------

/** Internal function called by +taskHandlerThread: which will load an image
 * (or get it from the cache if already in memory), scale the image to whatever
 * the requester asks for, and then pass the image back to the main thread.
 *
 * @param task Task Dictionary representing the current task
 *
 * @note This function is way too long; it is a textbook example of a function
 *       that is too long, takes on too many responsibilities and is confusing.
 */
+(void)doDisplayImage:(NSMutableDictionary*)task
{	
	id requester = [task objectForKey:@"Requester"];
	NSNumber* size;
	
	// It takes time to load data. Should we cancel?
	if(newTaskForSameRequester(task)) {
		[task release];
//		NSLog(@"Bailing at first sight!");
		return;	
	}
	
	[requester performSelectorOnMainThread:@selector(beginCountdownToDisplayProgressIndicator)
								withObject:nil
							 waitUntilDone:NO];		

	// Get an imageRep for the current image requested in task
	NSImageRep* imageRep = [self loadImageForTask:task 
								   cancelFunction:newTaskForSameRequester];
	size = [[task objectForKey:@"Data Size"] retain];
		
	// If we can't load the file, error out.
	if(imageRep == nil) {
		[task release];
		[size release];
		return;	
	}	

	// Now we get the target size of the image.
	NSSize displaySize = [self calculateTargetImageSize:task imageRep:imageRep];
	
	// It takes time to load data. Should we cancel?
	if(newTaskForSameRequester(task)) {
		[imageRep release];
		[task release];
		[size release];
//		NSLog(@"Bailing after building image size");
		return;
	}
	
	NSImage* imageToRet;
	NSString* smoothing = [task objectForKey:@"Smoothing"];
	
	BOOL noSmoothing = [smoothing isEqual:NO_SMOOTHING];
	BOOL naturalSize = ([imageRep pixelsWide] <= displaySize.width && 
						[imageRep pixelsHigh] <= displaySize.height);
	BOOL animated = imageRepIsAnimated(imageRep);
	if(noSmoothing || naturalSize || animated)
	{		
		// Draw the image by just making an NSImage from the imageRep. This is
		// done when the image will have no smoothing, or when we are 
		// rendering an animated GIF.
		imageToRet = [[NSImage alloc] init];
		[imageToRet addRepresentation:imageRep];
		
		// Scale it anyway, because some pictures LIE about their size.
		[imageToRet setScalesWhenResized:YES];
		[imageToRet setSize:NSMakeSize(displaySize.width, displaySize.height)];
		
		// Okay, if this image is animated, but it doesn't have have an frame
		// duration, we're dealing with a broken GIF. Hack it so that it has
		// a frame duration, even if it's wrong so at least there's some animation...
		if([imageRep isKindOfClass:[NSBitmapImageRep class]] &&
		   [[(NSBitmapImageRep*)imageRep valueForProperty:NSImageFrameCount] intValue] > 1 &&
		   ![(NSBitmapImageRep*)imageRep valueForProperty:NSImageCurrentFrameDuration] )
		{
			[(NSBitmapImageRep*)imageRep setProperty:NSImageCurrentFrameDuration
										   withValue:[NSNumber numberWithFloat:0.1f]];
		}
		
		// Now give us a chance to BAIL if we've already been given another display
		// command
		if(newTaskForSameRequester(task)) {
			[imageToRet release];
			[imageRep release];
//			NSLog(@"Bailing during quick render!");
			[task release];
			[size release];
			return;		
		}

		[task setObject:imageToRet forKey:@"Image"];
		// Bundle imageToRet up for transport across thread boundaries.
		[requester performSelectorOnMainThread:@selector(receiveImage:)
									withObject:task
								 waitUntilDone:NO];
	}
	else
	{
		// First, we draw the image with no interpolation, and send that 
		// representation to the screen for SPEED so it LOOKS like we are doing 
		// something.
		imageToRet = [[NSImage alloc] initWithSize:displaySize];
		
		// This block could throw on a bad file. We catch and error
		@try
		{
			[imageToRet lockFocus];
			{
				[[NSGraphicsContext currentContext] 
					setImageInterpolation:NSImageInterpolationNone];
				[imageRep drawInRect:NSMakeRect(0,0,displaySize.width,
												displaySize.height)];
			}
			[imageToRet unlockFocus];		
		}
		@catch(NSException* e)
		{
			// The image will still be locked, even if -lock fails.
			[imageToRet unlockFocus];
			[imageToRet release];
			
			NSLog(@"Exception: %@:%@", [e name] , [e reason]);
//			
//			// Alert the user to a problem
//			NSString* format = NSLocalizedString(@"Can not display %@", 
//												 @"Error message: 'Can not display FILENAME'");
//			NSString* informativeText = NSLocalizedString(@"Please chcek that it's a valid file",
//														  @"Localized informative text on can't load image error");
			
//			[vitaminSEEController stopProgressIndicator];
//			[vitaminSEEController displayAlert:[NSString stringWithFormat:
//				format, [path lastPathComponent]]
//							   informativeText:informativeText
//									helpAnchor:@"VITAMINSEE_IMAGE_WONT_LOAD_ANCHOR"];
			return;
		}

		// Now give us a chance to BAIL if we've already been given another display
		// command
		if(newTaskForSameRequester(task)) {
			[imageRep release];
			[imageToRet release];
			[task release];
			[size release];
//			NSLog(@"Bailing after first pass...");
			return;
		}
		
		// Bundle imageToRet up for transport across thread boundaries.
		NSMutableDictionary* taskCopy = [task mutableCopy];
		[task setObject:imageToRet forKey:@"Image"];
		[task setObject:[NSNumber numberWithBool:NO] forKey:@"Partial"];
		[imageToRet release];
		[requester performSelectorOnMainThread:@selector(receiveImage:)
									withObject:task
								 waitUntilDone:NO];
		
		// Draw the image onto a new NSImage using smooth scaling. This is done
		// whenever the image isn't animated so that the picture will have 
		// some antialiasin lovin' applied to it.
		@try
		{
			imageToRet = [[NSImage alloc] initWithSize:displaySize];
			[imageToRet lockFocus];
			{
				if([[taskCopy objectForKey:@"Smoothing"] isEqual:LOW_SMOOTHING])
				{
					[[NSGraphicsContext currentContext] 
						setImageInterpolation:NSImageInterpolationLow];
				}
				else
				{
					[[NSGraphicsContext currentContext] 
						setImageInterpolation:NSImageInterpolationHigh];
				}
				
				[imageRep drawInRect:NSMakeRect(0,0,displaySize.width,displaySize.													height)];
			}
			[imageToRet unlockFocus];
		}
		@catch(NSException* e)
		{
			// The image will still be locked, even if -lock fails.
			[imageToRet unlockFocus];
			[imageToRet release];
			
			NSLog(@"Exception: %@:%@", [e name] , [e reason]);
			
			// In this case, don't update the display; it just won't be as 
			// pretty on screen.
			return;
		}
		
		// Now give us a chance to BAIL if we've already been given another 
		// display command
		if(newTaskForSameRequester(taskCopy)) {
			[imageRep release];
			[imageToRet release];
			[taskCopy release];
			[size release];
//			NSLog(@"Bailing after second pass!");
			return;		
		}
		
		// Now display the final image:
		// Bundle imageToRet up for transport across thread boundaries.
		[taskCopy setObject:imageToRet forKey:@"Image"];
		[requester performSelectorOnMainThread:@selector(receiveImage:)
									withObject:taskCopy
								 waitUntilDone:NO];
	}		

	[imageToRet release];	
	[imageRep release];
	[size release];
	
	// An image has been displayed so stop the spinner
//	[vitaminSEEController stopProgressIndicator];
	
}

//-----------------------------------------------------------------------------

/** Loads a file into memory, checking to see if we should cancel every 300
 * kilobytes that we load from disk
 *
 * @param path EGPath to the file to load
 * @param cancelFunction Function pointer to function to check if we should cancel
 * @param task Task Dictionary passed to the cancelFunction
 * @note Caller is responsible for releasing returned object.
 */
+(NSData*)loadFile:(EGPath*)path cancelFunction:(CANCELCHECK)cancelFunction 
	  taskToCancel:(NSDictionary*)task
{
	// Open up the file, and allocate the memory that will eventually be used to
	// store our data.
	NSString* filesystemPath = [path fileSystemPath];
	FILE* inFile = fopen([filesystemPath fileSystemRepresentation], "r");
	if(inFile == 0)
	{
		NSLog(@"Error! Could not open file %@!", filesystemPath);
		return NULL;		
	}
	int fileSize = [filesystemPath fileSize];
	void* rawdata = malloc(fileSize);
	
	// Check to see if we should cancel every 300 kilobytes.
	const int iterations = 300 / 4;
	int fileSizeRemaining = fileSize;
	void* curPtr = rawdata;
	int count = 0;
	const int BLOCKSIZE = 1024 * 4;
	while(fileSizeRemaining > 0)
	{
		if(fileSizeRemaining > (BLOCKSIZE))
		{
			// Load data
			if(fread(curPtr, 1, BLOCKSIZE, inFile) != BLOCKSIZE) {
				// Read error. Bail.
				free(rawdata);
				fclose(inFile);
				return nil;
			}
			
			curPtr += BLOCKSIZE;
			fileSizeRemaining -= BLOCKSIZE;
			
			// It takes time to load data. Should we cancel?
			if(count > iterations) {
				if(cancelFunction && cancelFunction(task)) {
					// We're aborting the load; free the resources we're using.
					free(rawdata);
					fclose(inFile);
					return nil;
				}
				count = -1;
			}
			count++;
		}
		else
		{
			// Load the remaining chunk into memory.
			if(fread(curPtr, 1, fileSizeRemaining, inFile) != fileSizeRemaining) {
				// Read error. Bail.
				free(rawdata);
				fclose(inFile);
				return nil;				
			}
			fileSizeRemaining -= fileSizeRemaining;
		}
	}
	
	fclose(inFile);
	return [[NSData alloc] initWithBytesNoCopy:rawdata length:fileSize];	
}

//-----------------------------------------------------------------------------

/** Will load an image (or get it out of a cache), checking to see whether we
 * should cancel after every major step.
 *
 * @param task Task Dictionary
 * @param cancelFunction Callback function which is used to control whether we
 *        should cancel loading.
 * @return Unmodified NSImageRep of the image
 * @note Caller is responsible for releasing returned object.
 */
+(NSImageRep*)loadImageForTask:(NSMutableDictionary*)task 
				cancelFunction:(CANCELCHECK)cancelFunction
{
	// First, we load the data from 
	NSData* imageData;
	EGPath* path = [task objectForKey:@"Path"];
	
	if(!task) return nil;
	if(!path) return nil;
	
	// First we check to see if the data is already loaded and resident in the
	// cache.	
	NSEnumerator* e = [imageCache objectEnumerator];
	id obj;
	while(obj = [e nextObject])
	{
		if([[obj objectForKey:@"Path"] isEqual:path]) {
			id dataSize = [obj objectForKey:@"Data Size"];
			if(dataSize)
				[task setObject:dataSize forKey:@"Data Size"];
			
			return [[obj objectForKey:@"Image Rep"] retain];
		}
	}

	// If the file wasn't in the cache, then we need to load it.
	imageData = [self loadFile:path cancelFunction:cancelFunction taskToCancel:task];

	// Check to see if the current task was canceled.
	if(!imageData) {
		return nil;
	}
	
	// Now let's build the image
	Class imageRepClass = [NSImageRep imageRepClassForData:imageData];
	if(imageRepClass == nil) {
		// This should never happen, but let's make sure memory doesn't leak
		// all over the place in case it does.
		[imageData release];
		return nil;
	}

	// Load the image from the data loaded from disk.
	NSImageRep* imageRep = [[imageRepClass alloc] initWithData:imageData];
	NSNumber* filesize = [NSNumber numberWithInt:[imageData length]];
	[task setValue:filesize forKey:@"Data Size"];
	[imageData release];
	
	// It takes time to load data. Should we cancel?
	if(cancelFunction && cancelFunction(task)) {
		[imageRep release];
		return nil;
	}

	// OK, we took the trouble of loading this image, store it in the cache.
	[self evictImages];
	NSMutableDictionary* dict = [NSMutableDictionary 
		dictionaryWithObjectsAndKeys:[NSDate date], @"Date", 
		path, @"Path",
		imageRep, @"Image Rep",
		filesize, @"Data Size",
		nil];
	[imageCache setObject:dict forKey:path];
//	NSLog(@"Loading image '%@' from disk...", path);

	return imageRep;
}

//-----------------------------------------------------------------------------

/** Calculates the target size of the image, based on the options in the Task
 * Dictionary.
 *
 * @param task Task Dictionary
 * @param imageRep Orriginal representation of the image
 * @return The target size.
 */
+(NSSize)calculateTargetImageSize:(NSMutableDictionary*)task 
						 imageRep:(NSImageRep*)imageRep
{
	NSSize size;
	NSString* scaleMode = [task objectForKey:@"Scale Mode"];
	int imageWidth = [imageRep pixelsWide];
	int imageHeight = [imageRep pixelsHigh];
	
	// Add the height and width to our task list.
	[task setObject:[NSNumber numberWithInt:imageWidth] forKey:@"Pixel Width"];
	[task setObject:[NSNumber numberWithInt:imageHeight] forKey:@"Pixel Height"];
	
	if([scaleMode isEqual:SCALE_IMAGE_PROPORTIONALLY])
	{
		// Simply scale the image by the scale ratio if we're scaling the image
		// proportionally
		
		double scaleRatio = [[task objectForKey:@"Scale Ratio"] doubleValue];
		size.width = imageWidth * scaleRatio;
		size.height = imageHeight * scaleRatio;
	}
	else if([scaleMode isEqual:SCALE_IMAGE_TO_FIT])
	{
		float viewingAreaHeight = [[task objectForKey:@"Viewing Area Height"] 
			floatValue];
		float viewingAreaWidth = [[task objectForKey:@"Viewing Area Width"] 
			floatValue];
		
		// First check to see if the image will fit within the boundaries of the
		// window 
		if(imageWidth <= viewingAreaWidth && imageHeight <= viewingAreaHeight)
		{
			size.width = imageWidth;
			size.height = imageHeight;
		}
		else
		{
			// Find the best ratio
			float heightRatio = MIN(viewingAreaHeight/imageHeight,
									imageHeight/viewingAreaHeight);
			float widthRatio = MIN(viewingAreaWidth/imageWidth,
								   imageWidth/viewingAreaWidth);
			float maxRatio = MAX(heightRatio, widthRatio);
			float minRatio = MIN(heightRatio, widthRatio);

			float maxHeight = imageHeight * maxRatio;
			float maxWidth = imageWidth * maxRatio;
			
			if(maxHeight <= viewingAreaHeight && maxWidth <= viewingAreaWidth) 
			{
				size.width = maxWidth;
				size.height = maxHeight;
			}
			else
			{
				size.width = imageWidth * minRatio;
				size.height = imageHeight * minRatio;
			}			
		}
	}
	
	// Round down, so we don't have a scroll bar apear for 0.1 pixels.
	size.width = floor(size.width);
	size.height = floor(size.height);
	return size;
}

//-----------------------------------------------------------------------------

/** Internal function called by +taskHandlerThread: which will preload the image
 * file in path.
 *
 * @param path Path to image to preload
 */
+(void)doPreloadImage:(EGPath*)path
{
	if(![imageCache objectForKey:path]) 
	{		
		NSMutableDictionary* dictionary = [NSMutableDictionary 
			dictionaryWithObject:path forKey:@"Path"];
		[[self loadImageForTask:dictionary 
				 cancelFunction:newTaskThatPreemptsPreload] release];
	}
}

//-----------------------------------------------------------------------------

/** Evicts the oldest image in the cache. 
 */
+(void)evictImages
{
	if([imageCache count] > CACHE_SIZE)
	{
		NSString* oldestPath = nil;
		NSDate* oldestDate = [NSDate date];
		
		NSArray* currentImages = [imageCache allKeys];
		int i = 0, count = [currentImages count];
		for(; i < count; ++i)
		{
			NSString* cur = (NSString*)CFArrayGetValueAtIndex((CFArrayRef)
															currentImages, i);
			NSDictionary* cacheEntry = [imageCache objectForKey:cur];
			if([oldestDate compare:[cacheEntry objectForKey:@"Date"]] ==
			   NSOrderedDescending)
			{
				// this is older!
				oldestDate = [cacheEntry objectForKey:@"Date"];
				oldestPath = cur;
			}
		}
		
		[imageCache removeObjectForKey:oldestPath];
	}
}

@end
