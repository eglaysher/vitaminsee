/////////////////////////////////////////////////////////////////////////
// File:          $URL$
// Module:        Unit tests for the ImageLoader
// Part of:       VitaminSEE
//
// Revision:      $Revision$
// Last edited:   $Date$
// Author:        $Author$
// Copyright:     (c) 2005 Elliot Glaysher
// Created:       3/25/06
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

// ---------------------------------------------------------------------------

// Callback method that receives the image
-(void)receiveImage:(id)image
{
	NSLog(@"Receiving object!");
}

// ---------------------------------------------------------------------------

// Required method for communicating with the ImageLoader
-(NSNumber*)documentID
{
	return [NSNumber numberWithInt:100];
}

// ---------------------------------------------------------------------------

-(void)beginCountdownToDisplayProgressIndicator
{
	// Do nothing
}

@end
