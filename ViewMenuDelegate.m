/////////////////////////////////////////////////////////////////////////
// File:          $Name$
// Module:        Delegate object that displays the View menu.
// Part of:       VitaminSEE
//
// ID:            $Id: ApplicationController.m 123 2005-04-18 00:21:02Z elliot $
// Revision:      $Revision: 248 $
// Last edited:   $Date: 2005-07-13 20:26:59 -0500 (Wed, 13 Jul 2005) $
// Author:        $Author: elliot $
// Copyright:     (c) 2005 Elliot Glaysher
// Created:       12/27/05
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
	@"Fullscreen",
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
	@"F",
	@"l",
	@"",
	@"",
	@""
};

static SEL menuActions[13] = {0};

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
	menuActions[8] = @selector(becomeFullScreen:);
	menuActions[9] = @selector(toggleFileList:);
	menuActions[10] = 0;
	menuActions[11] = @selector(toggleToolbarShown:);
	menuActions[12] = @selector(runToolbarCustomizationPalette:);
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

		NSString* localalized = NSLocalizedString(menuName, @"View menu");
		
		[item setTitle:localalized];
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
		NSString* localalized = NSLocalizedString(title, @"View menu");
		
		if([title isEqual:@"---"]) 
		{
			[menu removeItemAtIndex:index];
			[menu insertItem:[NSMenuItem separatorItem] atIndex:index];
		}
		else
		{
			[item setTitle:localalized];
			[item setAction:menuActions[localIndex]];
			[item setKeyEquivalent:keyEquivalents[localIndex]];
		}
	}
	
	return YES;
}

@end
