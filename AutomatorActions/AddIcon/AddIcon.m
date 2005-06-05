//
//  AddIcon.m
//  AddIcon
//
//  Created by Elliot Glaysher on 6/3/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "AddIcon.h"
#import "IconFamily.h"
#import "NSString+FileTasks.h"

@implementation AddIcon

- (id)runWithInput:(id)input fromAction:(AMAction *)anAction error:(NSDictionary **)errorInfo
{
	// Add your code here, returning the data to be passed to the next action.
	NSEnumerator* e = [input objectEnumerator];
	NSString* file;
	while(file = [e nextObject])
	{
		if([file isImage])
		{
			// If this file already has an icon, we need to remove it.
			if([IconFamily fileHasCustomIcon:file])
				[IconFamily removeCustomIconFromFile:file];
			
			// Build the icon
			NSImage* image = [[[NSImage alloc] initWithData:
				[NSData dataWithContentsOfFile:file]] autorelease];
			
			// Set icon
			IconFamily* iconFamily = [IconFamily iconFamilyWithThumbnailsOfImage:image];
			if(iconFamily)
				[iconFamily setAsCustomIconForFile:file];
		}
	}
	
	// Pass on the input.
	return input;
}

@end
