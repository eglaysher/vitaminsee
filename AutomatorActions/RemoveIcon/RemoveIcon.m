//
//  RemoveIcon.m
//  RemoveIcon
//
//  Created by Elliot Glaysher on 6/4/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "RemoveIcon.h"
#import "IconFamily.h"

@implementation RemoveIcon

- (id)runWithInput:(id)input fromAction:(AMAction *)anAction error:(NSDictionary **)errorInfo
{
	// For each file that has a custom icon, remove it.
	NSEnumerator* e = [input objectEnumerator];
	NSString* filePath;
	while(filePath = [e nextObject])
		if([IconFamily fileHasCustomIcon:filePath])
			[IconFamily removeCustomIconFromFile:filePath];

	// Pass on the list of files
	return input;
}

@end
