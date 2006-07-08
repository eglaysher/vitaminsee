//
//  ImageLoader.m
//  VitaminSEE
//
//  Created by Elliot on 3/25/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "EGPath.h"
#import "ImageLoader.h"
#import "ImageLoaderTests.h"
#import "TestingUtilities.h"

@implementation ImageLoaderTests

/** This test case just checks that the internal doDisplayImage: method will
 * pick up 
 */
-(void)testBasicImageLoading
{
	NSString* projectDir = getProjectDir();
	EGPath* fileOne = [EGPath pathWithPath:[projectDir
		stringByAppendingPathComponent:@"UnitTests/Images/test1.png"]];
//	NSLog(@"fileOne: %@", fileOne);

	// Clear the image cache:
	[ImageLoader clearAllCaches];
	NSArray* cache = [ImageLoader imagesInCache];
	STAssertEquals([cache count], 0u, @"The cache wasn't cleared by clearAllCaches!");
	
	// Let's try loading an image:
	NSMutableDictionary* dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
		@"Scale Image to Fit", @"Scale Mode",
		[NSNumber numberWithDouble:500.0], @"Viewing Area Width",
		[NSNumber numberWithDouble:500.0], @"Viewing Area Height",
		@"No Smoothing", @"Smoothing",
		[NSNumber numberWithDouble:1.0], @"Scale Ratio",
		fileOne, @"Path", 
		self, @"Requester",
		nil];
	[ImageLoader doDisplayImage:dic debugMode:YES];

	// The image is in the cache
	cache = [ImageLoader imagesInCache];
	STAssertEquals([cache count], 1u, @"There isn't just one image in the cache!");
	STAssertEqualObjects([cache objectAtIndex:0], fileOne, 
				@"Something other then the file we requested is in the cache!");
}

// Callback method that receives the image
-(void)receiveImage:(id)image
{
	NSLog(@"Receiving object!");
}

// Required method for communicating with the ImageLoader
-(NSNumber*)documentID
{
	return [NSNumber numberWithInt:100];
}

-(void)beginCountdownToDisplayProgressIndicator
{
	// Do nothing
}

@end
