//
//  ImageLoader.m
//  VitaminSEE
//
//  Created by Elliot on 3/25/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "EGPath.h"
#import "ImageLoader.h"

@implementation ImageLoaderTests

-(void)testImageCache
{
	char* fileCS = getenv("TEST_IMAGE_DIR");
	NSString* file = [NSString stringWithCString:fileCS];
	EGPath* fileOne = [EGPath pathWithPath:[file stringByAppendingPathComponent:@"test1.png"]];
	NSLog(@"fileOne: %@", fileOne);
	
	// Clear the image cache:
	[ImageLoader clearAllCaches];
	
	// Let's try loading an image:
	NSMutableDictionary* dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
		SCALE_IMAGE_TO_FIT, @"Scale Mode",
		[NSNumber numberWithDouble:500.0], @"Viewing Area Width",
		[NSNumber numberWithDouble:500.0], @"Viewing Area Height",
		smoothing, @"Smoothing",
		[NSNumber numberWithDouble:1.0], @"Scale Ratio",
		fileOne, @"Path", 
		self, @"Requester",
		nil];
	[ImageLoader loadTask:dic];
	
	sleep(3);
}

@end
