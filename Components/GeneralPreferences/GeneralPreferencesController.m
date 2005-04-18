/////////////////////////////////////////////////////////////////////////
// File:          $Name$
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
	[oPanel setTitle:NSLocalizedString(@"Change startup folder", 
		@"Name in open dialog box when selecting new startup folder")];
	[oPanel setPrompt:NSLocalizedString(@"Change", 
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

// GENERAL_PREFERENCES_ANCHOR
-(IBAction)showHelp:(id)sender
{
	[[NSHelpManager sharedHelpManager] openHelpAnchor:@"GENERAL_PREFERENCES_ANCHOR"
											   inBook:@"VitaminSEE Help"];
}

/////////////////////////////////////////// Protocol: SS_PreferencePaneProtocol

+(NSArray*)preferencePanes
{
	return [NSArray arrayWithObjects:[[[GeneralPreferencesController alloc]
		init] autorelease], nil];
}

- (NSView *)paneView
{
    BOOL loaded = YES;
    
    if (!prefView)
        loaded = [NSBundle loadNibNamed:@"GeneralPreferences" owner:self];
    
    if (loaded)
        return prefView;
    
    return nil;
}

- (NSString *)paneName
{
    return NSLocalizedString(@"General", @"Localized name of preference pane in toolbar");
}

- (NSImage *)paneIcon
{
	// Fix this...
    return [[[NSImage alloc] initWithContentsOfFile:
        [[NSBundle bundleForClass:[self class]] pathForImageResource:@"General_Prefs"]
        ] autorelease];
}

- (NSString *)paneToolTip
{
    return NSLocalizedString(@"General Preferences", @"Tooltip in toolbar");
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
