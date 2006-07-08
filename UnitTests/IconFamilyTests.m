//
//  IconFamilyTests.m
//  VitaminSEE
//
//  Created by Elliot on 3/29/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "IconFamilyTests.h"
#import "TestingUtilities.h"

#import "EGPath.h"
#import "IconFamily.h"


@implementation IconFamilyTests

-(void)testToMakeSureModificationDatesAreRestored
{
	NSString* projectDir = getProjectDir();
	EGPath* fileOne = [EGPath pathWithPath:[projectDir
		stringByAppendingPathComponent:@"UnitTests/Images/test1.png"]];
	NSString* fileOneString = [fileOne fileSystemPath];
	
	// Get the current modification date of the file.
	NSDate* beforeDate = [[[NSFileManager defaultManager]
		fileAttributesAtPath:fileOneString traverseLink:NO] 
		objectForKey:NSFileModificationDate];
	
	NSImage* image = [[NSImage alloc] initWithContentsOfFile:fileOneString];
	IconFamily* iconfamily = [IconFamily iconFamilyWithThumbnailsOfImage:image];
	[image release];
	
	[iconfamily setAsCustomIconForFile:fileOneString];
		
	// Get the modification date of the file after setting the icon
	NSDate* afterDate = [[[NSFileManager defaultManager]
		fileAttributesAtPath:fileOneString traverseLink:NO] 
		objectForKey:NSFileModificationDate];
	
	STAssertEqualObjects(beforeDate, afterDate,
						 @"Modification dates differ (but should be equal!)");
}

@end
