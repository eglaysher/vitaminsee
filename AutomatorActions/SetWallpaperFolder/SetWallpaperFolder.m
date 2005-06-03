//
//  SetWallpaperFolder.m
//  SetWallpaperFolder
//
//  Created by Elliot Glaysher on 6/2/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "SetWallpaperFolder.h"
#import "DesktopBackground.h"
#import "NSString+FileTasks.h"
#import <Automator/Automator.h>

@implementation SetWallpaperFolder

- (id)runWithInput:(id)input fromAction:(AMAction *)anAction error:(NSDictionary **)errorInfo
{
	// Set the wallpaper folder from the first folder we see in input
	NSEnumerator* e = [input objectEnumerator];
	NSString* wallpaperFolder = 0;
	NSString* currentItem = 0;
	while(currentItem = [e nextObject])
	{
		if([currentItem isDir])
		{
			wallpaperFolder = currentItem;
			break;
		}
	}
	
	if(wallpaperFolder)
	{
		NSMutableDictionary* options = [NSMutableDictionary dictionary];
		
		// Set the wallpaper placement style
		int tag = [[[self parameters] objectForKey:@"wallpaperPlaccementTag"] intValue];
		switch(tag)
		{
			case 0:
				// Don't do anything
				break;
			case 1:
				[options setObject:@"Crop" forKey:@"Placement"];
				break;
			case 2:
				[options setObject:@"FillScreen" forKey:@"Placement"];
				break;
			case 3:
				[options setObject:@"Centered" forKey:@"Placement"];
				break;
			case 4:
				[options setObject:@"Tiled" forKey:@"Placement"];
				break;
			default:
				NSLog(@"Internal Error! Wall placement tag is %d.", tag);
				// Return so we don't screw up settings!
				return nil;
		}
		[options setObject:[NSNumber numberWithInt:tag] forKey:@"PlacementKeyTag"];
		
		// Set the time frame
		tag = [[[self parameters] objectForKey:@"timeIntervalTag"] intValue];
		switch(tag)
		{
			case 0:
				// Do no modification in case 0.
				break;
			case 1:
				[options setObject:[NSNumber numberWithFloat:5] 
							forKey:@"ChangeTime"];
				break;
			case 2:
				[options setObject:[NSNumber numberWithFloat:60]
							forKey:@"ChangeTime"];
				break;
			case 3:
				[options setObject:[NSNumber numberWithFloat:300]
							forKey:@"ChangeTime"];
				break;
			case 5:
				[options setObject:[NSNumber numberWithFloat:900]
							forKey:@"ChangeTime"];
				break;
			case 6:
				[options setObject:[NSNumber numberWithFloat:1800]
							forKey:@"ChangeTime"];
				break;
			case 7:
				[options setObject:[NSNumber numberWithFloat:3600]
							forKey:@"ChangeTime"];
				break;
			case 8:
				[options setObject:[NSNumber numberWithFloat:86400]
							forKey:@"ChangeTime"];
			case 9:
				[options setObject:@"Login" forKey:@"Change"];
				break;
			case 10:
				[options setObject:@"Wakeup" forKey:@"Change"];
				break;
			default:
				NSLog(@"Internal Error! Time interval tag is %d.", tag);
				// Return so we don't screw up settings!
				return nil;
		}		
		
		// If we are here, we have a valid tag so set it:
		[options setObject:[NSNumber numberWithInt:tag] forKey:@"TimerPopUpTag"];
		
		// Set the background!
		id desktopBackgroundSetter = [[[DesktopBackground alloc] init] autorelease];
		[desktopBackgroundSetter setDesktopBackgroundToFolder:wallpaperFolder
												withOptions:options];
		NSLog(@"Set current item: %@", wallpaperFolder);
	}
	else
	{
		*errorInfo = [NSDictionary dictionaryWithObjectsAndKeys:
			[NSNumber numberWithInt:errOSASystemError], OSAScriptErrorNumber,
			@"ERROR: No folders were passed in.", OSAScriptErrorMessage,
			nil];

		return nil;
	}
	
	return input;
}

@end
