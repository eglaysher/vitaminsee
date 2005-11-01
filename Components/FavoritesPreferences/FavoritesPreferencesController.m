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

#import "FavoritesPreferencesController.h"


@implementation FavoritesPreferencesController

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
	[panel setPrompt:NSLocalizedStringFromTableInBundle(@"Add", nil,
		[NSBundle bundleForClass:[self class]],
		@"Action button in add Favorite location open box")];
	[panel setTitle:NSLocalizedStringFromTableInBundle(@"Add paths to Favorites",
		nil, [NSBundle bundleForClass:[self class]],													   
		@"Window title for open box")];
	
	int result = [panel runModalForDirectory:[NSHomeDirectory() 
		stringByAppendingPathComponent:@"Pictures"]
										file:nil
									   types:nil];
	if(result == NSOKButton) {
		NSFileManager* fileManager = [NSFileManager defaultManager];
		NSArray *directoriesToAdd = [panel filenames];
		NSEnumerator *e = [directoriesToAdd objectEnumerator];
		NSString* path;
		while(path = [e nextObject])
		{
			NSDictionary* dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:path,
				@"Path", [fileManager displayNameAtPath:path], @"Name", nil];
			[listOfDirectories addObject:dict];			
		}
	}
}

-(IBAction)showHelp:(id)sender
{
	NSString* helpBookName = [[[NSBundle mainBundle] localizedInfoDictionary] objectForKey:@"CFBundleHelpBookName"];
	
	[[NSHelpManager sharedHelpManager] 
		openHelpAnchor:@"VITAMINSEE_FAVORITES_PREFERENCES_ANCHOR"
				inBook:helpBookName];
}

/////////////////////////////////////////// Protocol: SS_PreferencePaneProtocol

+(NSArray*)preferencePanes
{
	return [NSArray arrayWithObjects:[[[FavoritesPreferencesController alloc]
		init] autorelease], nil];
}

- (NSView *)paneView
{
    BOOL loaded = YES;
    
    if (!prefView)
        loaded = [NSBundle loadNibNamed:@"FavoritesPreferences" owner:self];
    
    if (loaded)
        return prefView;
    
    return nil;
}

- (NSString *)paneName
{
    return NSLocalizedString(@"Favorites", @"Localized name of preference pane in toolbar");
}

- (NSImage *)paneIcon
{
    return [[NSImage alloc] initWithContentsOfFile:
		[[NSBundle mainBundle] pathForImageResource:@"ToolbarFavoritesIcon"]];
}

- (NSString *)paneToolTip
{
    return NSLocalizedString(@"Favorites", @"Localized tooltip");
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
