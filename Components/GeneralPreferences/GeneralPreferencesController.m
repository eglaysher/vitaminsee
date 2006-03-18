/////////////////////////////////////////////////////////////////////////
// File:          $URL$
// Module:        Implements the General preferences panel
// Part of:       VitaminSEE
//
// Revision:      $Revision$
// Last edited:   $Date$
// Author:        $Author$
// Copyright:     (c) 2005 Elliot Glaysher
// Created:       2/24/05
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

#import "GeneralPreferencesController.h"


@implementation GeneralPreferencesController

-(IBAction)changeDefaultDirectory:(id)sender
{
	// Open a dialog modally. It's what iTunes does in the Advanced part of
	// preferences, which is what I'm trying to copy...
	int result;
    NSOpenPanel *oPanel = [NSOpenPanel openPanel];
	[oPanel setCanChooseDirectories:YES];
	[oPanel setCanChooseFiles:NO];
	[oPanel setAllowsMultipleSelection:NO];
	[oPanel setTitle:NSLocalizedStringFromTableInBundle(@"Change startup folder", 
		nil, [NSBundle bundleForClass:[self class]],
		@"Name in open dialog box when selecting new startup folder")];
	[oPanel setPrompt:NSLocalizedStringFromTableInBundle(@"Change", nil,
		[NSBundle bundleForClass:[self class]], 
		@"Action button in open dialog box")];
	
	NSString* currentDirectory = [[NSUserDefaults standardUserDefaults]
		objectForKey:@"DefaultStartupPath"];
	
    result = [oPanel runModalForDirectory:currentDirectory
									 file:nil types:nil];
	
    if (result == NSOKButton) {
        NSArray *filesToOpen = [oPanel filenames];

		// count should equal 1, but let's loop just to be safe.
        int i, count = [filesToOpen count];
        for (i=0; i<count; i++) {
			[[NSUserDefaults standardUserDefaults] setObject:[filesToOpen objectAtIndex:i]
													  forKey:@"DefaultStartupPath"];
        }
    }
}

// ---------------------------------------------------------------------------

// GENERAL_PREFERENCES_ANCHOR
-(IBAction)showHelp:(id)sender
{
	NSString* helpBookName = [[[NSBundle mainBundle] localizedInfoDictionary] objectForKey:@"CFBundleHelpBookName"];

	[[NSHelpManager sharedHelpManager] openHelpAnchor:@"GENERAL_PREFERENCES_ANCHOR"
											   inBook:helpBookName];
}

/////////////////////////////////////////// Protocol: SS_PreferencePaneProtocol

+(NSArray*)preferencePanes
{
	return [NSArray arrayWithObjects:[[[GeneralPreferencesController alloc]
		init] autorelease], nil];
}

// ---------------------------------------------------------------------------

- (NSView *)paneView
{
    BOOL loaded = YES;
    
    if (!prefView)
        loaded = [NSBundle loadNibNamed:@"GeneralPreferences" owner:self];
    
    if (loaded)
        return prefView;
    
    return nil;
}

// ---------------------------------------------------------------------------

- (NSString *)paneName
{
    return NSLocalizedString(@"General", @"Localized name of preference pane in toolbar");
}

// ---------------------------------------------------------------------------

- (NSImage *)paneIcon
{
	// Fix this...
    return [[[NSImage alloc] initWithContentsOfFile:
        [[NSBundle bundleForClass:[self class]] pathForImageResource:@"General_Prefs"]
        ] autorelease];
}

// ---------------------------------------------------------------------------

- (NSString *)paneToolTip
{
	NSString* tooltip = NSLocalizedStringFromTableInBundle(
		@"General Preferences", nil, [NSBundle bundleForClass:[self class]],
		@"Tooltip in toolbar");
	return tooltip;
}

// ---------------------------------------------------------------------------

- (BOOL)allowsHorizontalResizing
{
    return NO;
}

// ---------------------------------------------------------------------------

- (BOOL)allowsVerticalResizing
{
    return NO;
}

@end
