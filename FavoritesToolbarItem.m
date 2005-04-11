//
//  FavoritesToolbarItem.m
//  VitaminSEE
//
//  Created by Elliot on 4/9/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "VitaminSEEController.h"
#import "FavoritesToolbarItem.h"
#import "FavoritesMenuDelegate.h"
#import "PopUpImage.h"

@implementation FavoritesToolbarItem

-(id)initWithItemIdentifier:(NSString*)itemIdent 
				 controller:(VitaminSEEController*)inCont
{
	if(self = [super initWithItemIdentifier:itemIdent])
	{		
		popUpImage = [[PopUpImage alloc] initWithIcon:[NSImage imageNamed:@"ToolbarFavoritesIcon"]
											  popIcon:[NSImage imageNamed:@"arrow"]];
		
		// Set up the NSToolbarItem
		[self setLabel:NSLocalizedString(@"Favorites", @"Toolbar Item")];
		[self setPaletteLabel:NSLocalizedString(@"Favorites", @"Toolbar Item")];
		[self setToolTip:NSLocalizedString(@"Favorites", @"Toolbar Item")];

		// Set the size of the item
		// fixme: This is always large; we need a way to detect if this NSToolbar
		// is set to use small icons.
		[self setView:popUpImage];
		[self setMinSize:NSMakeSize(40,32)];
		[self setMaxSize:NSMakeSize(40,32)];

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
