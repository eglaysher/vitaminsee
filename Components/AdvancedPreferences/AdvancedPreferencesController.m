/////////////////////////////////////////////////////////////////////////
// File:          $Name$
// Module:        Implements the Favorites preference panel
// Part of:       VitaminSEE
//
// Revision:      $Revision: 155 $
// Last edited:   $Date: 2005-05-04 11:37:41 -0400 (Wed, 04 May 2005) $
// Author:        $Author: glaysher $
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
/////////////////////////////////////////////////////////////////////////

#import "AdvancedPreferencesController.h"


@implementation AdvancedPreferencesController

-(IBAction)showHelp:(id)sender
{
	NSString* helpBookName = [[[NSBundle mainBundle] localizedInfoDictionary] objectForKey:@"CFBundleHelpBookName"];
	
	[[NSHelpManager sharedHelpManager] 
		openHelpAnchor:@"VITAMINSEE_ADVANCED_PREFERENCES_ANCHOR"
				inBook:helpBookName];
}

/////////////////////////////////////////// Protocol: SS_PreferencePaneProtocol

+(NSArray*)preferencePanes
{
	return [NSArray arrayWithObjects:[[[AdvancedPreferencesController alloc]
		init] autorelease], nil];
}

-(NSView*)paneView
{
    BOOL loaded = YES;
    
    if (!prefView)
        loaded = [NSBundle loadNibNamed:@"AdvancedPreferences" owner:self];
    
    if (loaded)
        return prefView;
    
    return nil;
}

- (NSString *)paneName
{
    return NSLocalizedString(@"Advanced", @"Localized name of preference pane in toolbar");
}

- (NSImage *)paneIcon
{
    return [[NSImage alloc] initWithContentsOfFile:
		[[NSBundle mainBundle] pathForImageResource:@"AdvancedPreferences"]];
}

- (NSString *)paneToolTip
{
    return NSLocalizedString(@"Advanced", @"Localized tooltip");
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
