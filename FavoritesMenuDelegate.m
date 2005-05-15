/////////////////////////////////////////////////////////////////////////
// File:          $Name$
// Module:        Menu Delegate object that reads the list of favorite locations
//                and displays them in a menu.
// Part of:       VitaminSEE
//
// Revision:      $Revision$
// Last edited:   $Date$
// Author:        $Author$
// Copyright:     (c) 2005 Elliot Glaysher
// Created:       4/11/05
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

#import "FavoritesMenuDelegate.h"
#import "VitaminSEEController.h"
#import "NSString+FileTasks.h"

@implementation FavoritesMenuDelegate

-(id)initWithController:(VitaminSEEController*)inController
{
	if(self = [super init])
	{
		controller = inController;
	}
	
	return self;
}

-(int)numberOfItemsInMenu:(NSMenu*)menu
{
	return [[[NSUserDefaults standardUserDefaults] 
		objectForKey:@"SortManagerPaths"] count];
}

- (BOOL)menu:(NSMenu *)menu 
  updateItem:(NSMenuItem *)item 
	 atIndex:(int)index 
shouldCancel:(BOOL)shouldCancel
{
	NSDictionary* d = [[[NSUserDefaults standardUserDefaults] 
		objectForKey:@"SortManagerPaths"] objectAtIndex:index];

	[item setTitle:[d objectForKey:@"Name"]];
	[item setAction:@selector(setDirectoryFromFavorites:)];
	[item setKeyEquivalent:@""];
	[item setRepresentedObject:[d objectForKey:@"Path"]];
	[item setTarget:self];
}

// This compatibility function is for the NSToolbarItem menuRepresentations.
// It has major problems dealing with NSMenus with delegates, so return
// an NSMenu with the items prebuilt.
-(NSMenu*)buildCompatibleMenu 
{
	NSMenu* menu = [[[NSMenu alloc] initWithTitle:@"Favorites"] autorelease];
	int count = [self numberOfItemsInMenu:nil];
	int i = 0;
	for(i = 0; i < count; ++i)
	{
		NSMenuItem* item = [[[NSMenuItem alloc] init] autorelease];
		[self menu:menu updateItem:item atIndex:i shouldCancel:NO];
		[menu addItem:item];
	}
	
	return menu;
}

-(BOOL)validateMenuItem:(NSMenuItem *)theMenuItem
{
	return [[theMenuItem representedObject] isDir];
}

-(void)setDirectoryFromFavorites:(id)menu
{
	[controller finishedGotoFolder:[menu representedObject]];
}

@end
