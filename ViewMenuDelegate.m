//
//  ViewMenuDelegate.m
//  VitaminSEE
//
//  Created by Elliot Glaysher on 12/27/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "ViewMenuDelegate.h"
#import "ComponentManager.h"

// Here is the structure to the View menu:
//
//  < List of available FileLists >
//  -------------------------------
//  Actual Size
//  Zoom In
//  Zoom Out
//  Zoom to fit
//  -------------------------------
//  Reveal in Finder
//  -------------------------------
//  Show File List
//  -------------------------------
//  Show Toolbar
//  Customize Toolbar...

// Create an array for easy lookup of 
static NSString* menuTitles[] = {
	@"---",
	@"Actual Size",
	@"Zoom In",
	@"Zoom Out",
	@"Zoom to fit",
	@"---",
	@"Reveal in Finder",
	@"---",
	@"Show File List",
	@"---",
	@"Show Toolbar",
	@"Customize Toolbar..."
};

static NSString* keyEquivalents[] = {
	@"",
	@"0",
	@"+",
	@"-",
	@"f",
	@"",
	@"",
	@"",
	@"l",
	@"",
	@"",
	@""
};

static SEL menuActions[12] = {0};

@implementation ViewMenuDelegate

+(void)initialize
{
	menuActions[0] = 0;
	menuActions[1] = @selector(actualSize:);
	menuActions[2] = @selector(zoomIn:);
	menuActions[3] = @selector(zoomOut:);
	menuActions[4] = @selector(zoomToFit:);
	menuActions[5] = 0;
	menuActions[6] = @selector(revealInFinder:);
	menuActions[7] = 0;
	menuActions[8] = @selector(toggleFileList:);
	menuActions[9] = 0;
	menuActions[10] = @selector(toggleToolbarShown:);
	menuActions[11] = @selector(runToolbarCustomizationPalette:);
}

- (int)numberOfItemsInMenu:(NSMenu *)menu
{	
	int count = 0;

	// If we have more then one file
	int fileListCount = [[ComponentManager getFileListsToDisplayInMenu] count];
	if(fileListCount > 1)
		count += fileListCount + 1;

	count += 11;
	return count;
}

/** Generate 
 *
 */
- (BOOL)menu:(NSMenu *)menu
  updateItem:(NSMenuItem *)item 
	 atIndex:(int)index 
shouldCancel:(BOOL)shouldCancel
{
	NSArray* fileLists = [ComponentManager getFileListsToDisplayInMenu];
	BOOL shouldDisplayFileLists = [fileLists count] > 1;
	
	if(shouldDisplayFileLists && index < [fileLists count]) 
	{
		NSString* menuName = [[fileLists objectAtIndex:index] 
			objectForKey:@"MenuName"];
		NSString* fileListName = [[fileLists objectAtIndex:index]
			objectForKey:@"PluginName"];

		[item setTitle:menuName];
		[item setAction:@selector(setFileListFromMenu:)];
		[item setRepresentedObject:fileListName];

		// Give the first five a key combination of cmd-#.
		if(index < 4) {
			int number = index + 1;
			NSString* key = [[NSNumber numberWithInt:number] stringValue];
			[item setKeyEquivalent:key];
			[item setKeyEquivalentModifierMask:NSCommandKeyMask];
		}
	}
	else
	{
		int localIndex;
		if(shouldDisplayFileLists)
			localIndex = index - [fileLists count];
		else
			localIndex = index + 1;
		
		NSString* title = menuTitles[localIndex];
		
		if([title isEqual:@"---"]) 
		{
			[menu removeItemAtIndex:index];
			[menu insertItem:[NSMenuItem separatorItem] atIndex:index];
		}
		else
		{
			[item setTitle:title];
			[item setAction:menuActions[localIndex]];
			[item setKeyEquivalent:keyEquivalents[localIndex]];
		}
	}
	
	return YES;
}

@end
