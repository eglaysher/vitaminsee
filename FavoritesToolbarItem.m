//
//  FavoritesToolbarItem.m
//  VitaminSEE
//
//  Created by Elliot on 4/9/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

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
}

@end
