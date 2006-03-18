/////////////////////////////////////////////////////////////////////////
// File:          $URL$
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

#import "FavoritesMenuDelegate.h"
#import "EGPath.h"
#import "NSString+FileTasks.h"
#import "ApplicationController.h"

@implementation FavoritesMenuDelegate

/** Returns the number of entries that should be in the menu.
 */
-(int)numberOfItemsInMenu:(NSMenu*)menu
{
	return [[[NSUserDefaults standardUserDefaults] 
		objectForKey:@"SortManagerPaths"] count];
}

//-----------------------------------------------------------------------------

/** Lazily initializes a menu item to a menu item to represent the index-th
 * path.
 */
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
	
	return YES;
}

//-----------------------------------------------------------------------------

/** This compatibility function is for the NSToolbarItem menuRepresentations.
 * It has major problems dealing with NSMenus with delegates, so return
 * an NSMenu with the items prebuilt.
 */
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

//-----------------------------------------------------------------------------

/** Menu validation function. Checks to make sure that the directory, in fact,
 * exists, and that it hasn't been deleted/moved/whatevered since the time of
 * adding to Favorites.
 */
-(BOOL)validateMenuItem:(NSMenuItem *)theMenuItem
{
	return [[theMenuItem representedObject] isDir];
}

//-----------------------------------------------------------------------------

/** Menu action for all menu items created in this delegate. Sets the directory
 * for whatever is the main window...
 */
-(void)setDirectoryFromFavorites:(id)menu
{
	[[ApplicationController controller] goToDirectory:[EGPath pathWithPath:
		[menu representedObject]]];
}

@end
