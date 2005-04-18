/////////////////////////////////////////////////////////////////////////
// File:          $Name$
// Module:        Implements the Favorites preference panel
// Part of:       VitaminSEE
//
// Revision:      $Revision$
// Last edited:   $Date$
// Author:        $Author$
// Copyright:     (c) 2005 Elliot Glaysher
// Created:       2/22/05
//
/////////////////////////////////////////////////////////////////////////
//
// This library is free software; you can redistribute it and/or
// modify it under the terms of the GNU Lesser General Public
// License as published by the Free Software Foundation; either
// version 2.1 of the License, or (at your option) any later version.
//  
// This library is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
// Lesser General Public License for more details.
//  
// You should have received a copy of the GNU Lesser General Public
// License along with this library; if not, write to the Free Software
// Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  
// USA
//
/////////////////////////////////////////////////////////////////////////

#import "SortManagerPreferencesController.h"


@implementation SortManagerPreferencesController

-(IBAction)add:(id)sender
{
	// Ask the user what directories to add. Use a panel instead of a sheet for
	// two reasons:
	//
	// a) iTunes Preference pane looks like us and IT opens a new panel instead
	//    of a sheet. I doubt an Apple app would go agaisnt the HIG.
	// b) This is easier. I'd have to modify the framework so that these plugins
	//    are aware of the parent window.
	NSOpenPanel* panel = [NSOpenPanel openPanel];
	[panel setCanChooseDirectories:YES];
	[panel setCanChooseFiles:NO];
	[panel setAllowsMultipleSelection:YES];
	[panel setCanCreateDirectories:YES];
	[panel setPrompt:@"Add"];
	[panel setTitle:@"Add paths to Sort Manager"];
	
	int result = [panel runModalForDirectory:[NSHomeDirectory() 
		stringByAppendingPathComponent:@"Pictures"]
										file:nil
									   types:nil];
	if(result == NSOKButton) {
		NSArray *directoriesToAdd = [panel filenames];
		NSEnumerator *e = [directoriesToAdd objectEnumerator];
		NSString* path;
		while(path = [e nextObject])
		{
			NSDictionary* dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:path,
				@"Path", [path lastPathComponent], @"Name", nil];
			[listOfDirectories addObject:dict];			
		}
	}
}

// SORT_MANAGER_PREFERENCES_ANCHOR
-(IBAction)showHelp:(id)sender
{
	[[NSHelpManager sharedHelpManager] openHelpAnchor:@"SORT_MANAGER_PREFERENCES_ANCHOR"
											   inBook:@"VitaminSEE Help"];
}

/////////////////////////////////////////// Protocol: SS_PreferencePaneProtocol

+(NSArray*)preferencePanes
{
	return [NSArray arrayWithObjects:[[[SortManagerPreferencesController alloc]
		init] autorelease], nil];
}

- (NSView *)paneView
{
    BOOL loaded = YES;
    
    if (!prefView)
        loaded = [NSBundle loadNibNamed:@"SortManagerPreferences" owner:self];
    
    if (loaded)
        return prefView;
    
    return nil;
}

- (NSString *)paneName
{
    return @"Favorites";
}

- (NSImage *)paneIcon
{
    return [[NSImage alloc] initWithContentsOfFile:
		[[NSBundle mainBundle] pathForImageResource:@"ToolbarFavoritesIcon"]];
}

- (NSString *)paneToolTip
{
    return @"Favorites";
}

- (BOOL)allowsHorizontalResizing
{
    return NO;
}

- (BOOL)allowsVerticalResizing
{
    return NO;
}

@end
