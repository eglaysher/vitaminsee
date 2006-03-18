/////////////////////////////////////////////////////////////////////////
// File:          $URL$
// Module:        Build the toolbar item for the favorites menu
// Part of:       VitaminSEE
//
// Revision:      $Revision$
// Last edited:   $Date$
// Author:        $Author$
// Copyright:     (c) 2005 Elliot Glaysher
// Created:       4/9/05
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

#import "MVMenuButton.h"
#import "FavoritesToolbarItem.h"
#import "FavoritesMenuDelegate.h"

@implementation FavoritesToolbarItem

/** Creates a "Favorites" toolbar menu item.
 */
-(id)initWithItemIdentifier:(NSString*)itemIdent 
{
	if(self = [super initWithItemIdentifier:itemIdent])
	{		
		popUpImage = [[MVMenuButton alloc] initWithFrame:
			NSMakeRect(0, 0, 32, 32)];
		[popUpImage setImage:[NSImage imageNamed:@"ToolbarFavoritesIcon"]];
		[popUpImage setToolbarItem:self];
		
		// Set up the NSToolbarItem
		[self setLabel:NSLocalizedString(@"Favorites", @"Toolbar Item")];
		[self setPaletteLabel:NSLocalizedString(@"Favorites", @"Toolbar Item")];
		[self setToolTip:NSLocalizedString(@"Favorites", @"Toolbar Item")];

		// Set the size of the item
		[self setView:popUpImage];
		[self setMinSize:NSMakeSize(32,32)];
		[self setMaxSize:NSMakeSize(32,32)];
		
		// Build menu
		favoritesMenu = [[NSMenu alloc] init];
		favoritesMenuDelegate = [[FavoritesMenuDelegate alloc] init];
		[favoritesMenu setDelegate:favoritesMenuDelegate];

		// Set up menu for the popup image.
		[popUpImage setMenu:favoritesMenu];
		
		// Set up menu representation for item
		menuRepresentation = [[NSMenuItem alloc] init];

		// Set the toolbar image to the Favorites heart
		NSImage* image = [[[NSImage imageNamed:@"ToolbarFavoritesIcon"] copy] autorelease];
		[image setScalesWhenResized:YES];
		[image setSize:NSMakeSize(16,16)];
		[menuRepresentation setImage:image];	
		
		[menuRepresentation setTitle:NSLocalizedString(@"Favorites", @"Toolbar Item")];
		[self rebuildOverflowAndOtherMenu:self];
		[self setMenuFormRepresentation:menuRepresentation];		
		
		// Listen for a change in the user defaults and rebuild this menu
		// when/if it happens. Again, this really should be done with the
		// delegate I wrote, but NSToolbarItem's menuRepresentation has 
		// problems with NSMenu's that use delegates so we have to do this
		// manually.
		NSNotificationCenter* c = [NSNotificationCenter defaultCenter];
		[c addObserver:self
			  selector:@selector(rebuildOverflowAndOtherMenu:)
				  name:NSUserDefaultsDidChangeNotification
				object:nil];
	}
	
	return self;
}

//-----------------------------------------------------------------------------

/** Deallocator 
 */
-(void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[popUpImage release];
	[favoritesMenu release];
	[favoritesMenuDelegate release];
	[menuRepresentation release];
	[super dealloc];
}

//-----------------------------------------------------------------------------

/** Notification handler function for "NSUserDefaultsDidChangeNotification".
 * Regenerates the Favorites menu. 
 * 
 * Really, this is a hack around broken delegate support for NSMenus in 
 * NSToolbarItems in text or overflow mode. This wasn't even fixed in Tiger the
 * last time I checked, not that it matters, since I'd have to drop 
 * compatibility with all previous versions of the AppKit.
 */
-(void)rebuildOverflowAndOtherMenu:(id)sender
{	
	[menuRepresentation setSubmenu:[favoritesMenuDelegate buildCompatibleMenu]];
}

@end
