/////////////////////////////////////////////////////////////////////////
// File:          $URL$
// Module:        Unit tests for the IconFamily
// Part of:       VitaminSEE
//
// Revision:      $Revision$
// Last edited:   $Date$
// Author:        $Author$
// Copyright:     (c) 2005 Elliot Glaysher
// Created:       3/29/06
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
