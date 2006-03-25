//
//  EGPathTests.m
//  VitaminSEE
//
//  Created by Elliot on 3/25/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "EGPath.h"
#import "EGPathTests.h"


@implementation EGPathTests

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

@end
