/////////////////////////////////////////////////////////////////////////
// File:          $URL$
// Module:        Unit tests for EGPath
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
#import "EGPathTests.h"


@implementation EGPathTests

/** Tests the unique equal properties of the root object.
 */
-(void)testEGPathRoot
{
	// Test creation
	EGPath* root1 = [EGPath root];
	STAssertNotNil(root1, @"Could not create EGPath root object (1)");
	EGPath* root2 = [EGPath root];
	STAssertNotNil(root1, @"Could not create EGPath root object (2)");
	
	// Make sure their hashes are equal
	STAssertEquals([root1 hash], [root2 hash],
				   @"Hashes for two EGPath root objects are not equal");
	STAssertEqualObjects(root1, root2, @"Two EGPath root objects are not equal.");
	
	// The parent of root is another root
	STAssertEqualObjects(root1, [root1 pathByDeletingLastPathComponent],
						 @"The parent of a root is something other then root!");
	
	// Make sure they return the same contents
	STAssertEquals([[root1 pathComponents] isEqualToArray:[root2 pathComponents]], YES,
				   @"The components of two roots differ!");
	STAssertEquals([[root1 directoryContents] isEqualToArray:[root2 directoryContents]], YES,
				   @"The contents of two roots differ!");
	STAssertEquals([[root1 displayName] isEqualToString:[root2 displayName]], YES,
				   @"The display names of two roots differ!");
	STAssertEquals([root1 exists], YES, @"Root does not exist! (!?!?!?)");
	STAssertEquals([root1 isRoot], YES, @"Root is not root!");
	STAssertEquals([root1 isNaturalFile], NO, @"Root is a natrual file location.");
	STAssertEquals([root1 isDirectory], YES, @"Root is not a directory (!?)");
}

// ---------------------------------------------------------------------------

/** Tests a normal EGPath object
 *
 */
-(void)testEGPath
{
	EGPath* home1 = [EGPath pathWithPath:[@"~" stringByExpandingTildeInPath]];
	EGPath* home2 = [EGPath pathWithPath:[@"~" stringByExpandingTildeInPath]]; 
	
	// Two EGPath objects that point to the same directory have the same 
	// properties
	STAssertEqualObjects(home1, home2, @"Two equal EGPath objects aren't.");
	STAssertEquals([home1 hash], [home2 hash],
				   @"Hashes for two equal EGPath objects are not equal");
	STAssertEquals([[home1 pathComponents] isEqualToArray:[home2 pathComponents]], YES,
				   @"The components of two homes differ!");
	STAssertEquals([[home1 directoryContents] isEqualToArray:[home2 directoryContents]], YES,
				   @"The contents of two homes differ!");
	STAssertEquals([[home1 displayName] isEqualToString:[home2 displayName]], YES,
				   @"The display names of two homes differ!");
	
	// The properties  
	STAssertEquals([home1 exists], YES, @"Root does not exist! (!?!?!?)");
	STAssertEquals([home1 isRoot], NO, @"Normal object is root!");
	STAssertEquals([home1 isNaturalFile], YES, @"Root is a natrual file location.");
	STAssertEquals([home1 isDirectory], YES, @"Root is not a directory (!?)");	
	
	// The parent of "/" should be root
	EGPath* rootHDDir = [EGPath pathWithPath:@"/"];
	EGPath* rootVFSDir = [EGPath root];
	STAssertEqualObjects([rootHDDir pathByDeletingLastPathComponent], rootVFSDir,
						 @"The parent of \"/\" isn't EGPathRoot!");
}

@end
