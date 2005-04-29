/////////////////////////////////////////////////////////////////////////
// File:          $Name$
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

#import "MVMenuButton.h"
#import "VitaminSEEController.h"
#import "FavoritesToolbarItem.h"
#import "FavoritesMenuDelegate.h"

@implementation FavoritesToolbarItem

-(id)initWithItemIdentifier:(NSString*)itemIdent 
				 controller:(VitaminSEEController*)inCont
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
		favoritesMenuDelegate = [[FavoritesMenuDelegate alloc] initWithController:inCont];
		[favoritesMenu setDelegate:favoritesMenuDelegate];

		// Set up menu for the popup image.
		[popUpImage setMenu:favoritesMenu];
		
		// Set up menu representation for item
		NSMenuItem* menuRepresentation = [[[NSMenuItem alloc] init] autorelease];
		[menuRepresentation setSubmenu:favoritesMenu];
		[menuRepresentation setTitle:@"Favorites"];
		[self setMenuFormRepresentation:menuRepresentation];		
	}
	
	return self;
}

-(void)dealloc
{
	[popUpImage release];
	[favoritesMenu release];
	[favoritesMenuDelegate release];
	[super dealloc];
}

@end
