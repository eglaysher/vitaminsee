/////////////////////////////////////////////////////////////////////////
// File:          $Name$
// Module:        Seperate thread for building of thumbnails.
// Part of:       VitaminSEE
//
// Revision:      $Revision$
// Last edited:   $Date$
// Author:        $Author$
// Copyright:     (c) 2005 Elliot Glaysher
// Created:       3/18/05
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

#import "ThumbnailManager.h"
#import "Util.h"
#import "IconFamily.h"
#import "VitaminSEEController.h"
#import "NSString+FileTasks.h"

#define CACHE_SIZE 3

@interface ThumbnailManager (Private)
-(void)doBuildIcon:(NSDictionary*)options;
@end

@implementation ThumbnailManager

// USE THESE DNS SERVERS!!!!!
// 141.213.4.4
// 141.213.4.5

-(id)initWithController:(id)parentController
{
	if(self = [super init])
	{
		pthread_mutex_init(&imageScalingProperties, NULL);
		pthread_mutex_init(&taskQueueLock, NULL);
		pthread_cond_init(&conditionLock, NULL);
		
		thumbnailQueue = [[NSMutableArray alloc] init];
		thumbnailLoadingPosition = 0;
		
		// Now we start work on thread communication.
		NSPort *port1 = [NSPort port];
		NSPort *port2 = [NSPort port];
		NSConnection* kitConnection = [[NSConnection alloc] 
			initWithReceivePort:port1 sendPort:port2];
		[kitConnection setRootObject:parentController];
		
		NSArray *portArray = [NSArray arrayWithObjects:port2, port1, nil];		
		
//		NSLog(@"PC: %@", parentController);
		
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
	pthread_mutex_destroy(&imageScalingProperties);
	pthread_mutex_destroy(&taskQueueLock);
	pthread_cond_destroy(&conditionLock);
	
	// destroy our mutexed data!
	[thumbnailQueue release];
	[super dealloc];
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
	
	// Don't delude ourselves. We're not as important as displaying images
	[NSThread setThreadPriority:0.3];
	
	// Handle queue
	while(1)
	{
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		
		// Let's wait for stuff
		pthread_mutex_lock(&taskQueueLock);
		while([thumbnailQueue count] == 0)
		{
			if(pthread_cond_wait(&conditionLock, &taskQueueLock))
				NSLog(@"Invalid wait!?");
		}

		if([thumbnailQueue count])
		{
			if(thumbnailLoadingPosition > [thumbnailQueue count])
				thumbnailLoadingPosition = 0;
			
			NSDictionary* action = [[thumbnailQueue 
				objectAtIndex:thumbnailLoadingPosition] retain];
			[thumbnailQueue removeObjectAtIndex:thumbnailLoadingPosition];
			pthread_mutex_unlock(&taskQueueLock);
			
			[self doBuildIcon:action];
			[action release];
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

-(void)setShouldBuildIcon:(BOOL)newShouldBuildIcon
{
	pthread_mutex_lock(&imageScalingProperties);
	shouldBuildIcon = newShouldBuildIcon;
	pthread_mutex_unlock(&imageScalingProperties);
}

-(void)buildThumbnail:(NSString*)path
{
	NSDictionary* currentTask = [NSDictionary dictionaryWithObjectsAndKeys:
		@"PreloadImage", @"Type", path, @"Path", nil];
	
	pthread_mutex_lock(&taskQueueLock);
	//	NSLog(@"Going to preload: %@", path);
	// Add the object
	[thumbnailQueue addObject:currentTask];
	
	// Note that we are OUT of here...
	pthread_cond_signal(&conditionLock);
	pthread_mutex_unlock(&taskQueueLock);	
}

-(void)setThumbnailLoadingPosition:(int)newPosition
{
	pthread_mutex_lock(&taskQueueLock);
	if(newPosition < [thumbnailQueue count])
		thumbnailLoadingPosition = newPosition;
	pthread_mutex_unlock(&taskQueueLock);
}

-(NSString*)getCurrentPath
{
	return currentPath;
}

-(NSImage*)getCurrentThumbnail
{
	return currentIconFamilyThumbnail;
}

-(void)clearThumbnailQueue
{
	pthread_mutex_lock(&taskQueueLock);
	[thumbnailQueue removeAllObjects];
	pthread_mutex_unlock(&taskQueueLock);
}

@end

@implementation ThumbnailManager (Private)

-(void)doBuildIcon:(NSDictionary*)options
{
	NSString* path = [options objectForKey:@"Path"];
	NSImage* thumbnail;
	IconFamily* iconFamily;
	
	pthread_mutex_lock(&imageScalingProperties);
	BOOL localShouldBuild = shouldBuildIcon;
	pthread_mutex_unlock(&imageScalingProperties);
	
	// Build the thumbnail and set it to the file...
	if([path isImage] && ![IconFamily fileHasCustomIcon:path] && localShouldBuild)
	{
		[vitaminSEEController setStatusText:[NSString 
			stringWithFormat:@"Building thumbnail for %@...", [path lastPathComponent]]];

		// I don't think there IS an autorelease...
		NSImage* image = [[[NSImage alloc] initWithData:[NSData dataWithContentsOfFile:path]] autorelease];

		// Set icon
		iconFamily = [IconFamily iconFamilyWithThumbnailsOfImage:image];
		if(iconFamily)
		{
			[iconFamily setAsCustomIconForFile:path];

			// Must retain
			thumbnail = [[iconFamily imageWithAllReps] retain];

			currentIconFamilyThumbnail = thumbnail;
			currentPath = path;
			[vitaminSEEController setIcon];

			[vitaminSEEController setStatusText:nil];
		}
	}
}

@end