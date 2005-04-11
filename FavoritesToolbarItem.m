//
//  FavoritesToolbarItem.m
//  VitaminSEE
//
//  Created by Elliot on 4/9/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "FavoritesToolbarItem.h"
#import "PopUpImage.h"

@implementation FavoritesToolbarItem

-(id)initWithItemIdentifier:(NSString*)itemIdent 
				 controller:(VitaminSEEController*)inCont
{
	if(self = [super initWithItemIdentifier:itemIdent])
	{		
		controller = inCont;
		
		popUpImage = [[PopUpImage alloc] initWithIcon:[NSImage imageNamed:@"ToolbarFavoritesIcon"]
											  popIcon:[NSImage imageNamed:@"arrow"]];
		
		// Set up the NSToolbarItem
		[self setLabel:NSLocalizedString(@"Favorites", @"Toolbar Item")];
		[self setPaletteLabel:NSLocalizedString(@"Favorites", @"Toolbar Item")];
		[self setToolTip:NSLocalizedString(@"Favorites", @"Toolbar Item")];

		// Fix this.
		[self setView:popUpImage];
		[self setMinSize:NSMakeSize(40,32)];
		[self setMaxSize:NSMakeSize(40,32)];

//		[self setImage:[NSImage imageNamed:@"ToolbarPicturesFolderIcon"]];
		
		// Build the menu for the first time
		[self rebuildFavoritesMenu];
		
		// Register to get NSUserDefaults
		// fixme: this should really be a KVO statement instead.
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(rebuildFavoritesMenu)
													 name:NSUserDefaultsDidChangeNotification
												   object:nil];
	}
	
	return self;
}

-(void)dealloc
{
	[popUpImage release];
}

-(void)rebuildFavoritesMenu
{
	NSMenu* menu = [[[NSMenu alloc] init] autorelease];
	NSEnumerator* e = [[[NSUserDefaults standardUserDefaults] objectForKey:@"SortManagerPaths"] objectEnumerator];
	NSDictionary* d;
	while(d = [e nextObject])
	{
		NSMenuItem* item = [[[NSMenuItem alloc] initWithTitle:[d objectForKey:@"Name"]
													   action:@selector(setDirectoryFromFavorites:)
												keyEquivalent:@""] autorelease];
//		NSLog(@"Item: %@", item);
		[item setRepresentedObject:[d objectForKey:@"Path"]];
		[item setTarget:self];
		[menu addItem:item];
	}
	
//	NSLog(@"Begining stuff");
	[popUpImage setMenu:menu];
	NSMenuItem* menuRepresentation = [[[NSMenuItem alloc] init] autorelease];
	[menuRepresentation setSubmenu:menu];
	[menuRepresentation setTitle:@"Favorites"];
	[self setMenuFormRepresentation:menuRepresentation];
//	NSLog(@"Ending stuff");
}

-(void)setDirectoryFromFavorites:(id)menu
{
//	NSLog(@"Setting to '%@'", [menu representedObject]);
	[controller finishedGotoFolder:[menu representedObject]];
}

@end
