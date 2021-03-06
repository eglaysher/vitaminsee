/////////////////////////////////////////////////////////////////////////
// File:          $URL$
// Module:        Plugin to build various stuff related to Favorites.
// Part of:       VitaminSEE
//
// Revision:      $Revision$
// Last edited:   $Date$
// Author:        $Author$
// Copyright:     (c) 2005 Elliot Glaysher
// Created:       10/23/05
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

#import "FavoritesMenuFactory.h"
#import "FavoritesMenuDelegate.h"
#import "FavoritesToolbarItem.h"

#import "NSString+FileTasks.h"

@implementation FavoritesMenuFactory

-(id)buildMenuDelegate
{
	return [[FavoritesMenuDelegate alloc] init];
}

-(id)buildToolbarItemWithIdentifier:(NSString*)itemIdent
{
	return [[FavoritesToolbarItem alloc] initWithItemIdentifier:itemIdent];
}

-(void)addDirectoryToFavorites:(NSString*)directory
{
	// Adds the currently selected directory to the favorites menu
	if([directory isDir])
	{
		NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
		NSMutableArray* favoritesArray = [[userDefaults objectForKey:
			@"SortManagerPaths"] mutableCopy];
		
		NSDictionary* newItem = [NSDictionary dictionaryWithObjectsAndKeys:
			[directory lastPathComponent], @"Name",
			directory, @"Path", nil];
		[favoritesArray addObject:newItem];
		[userDefaults setValue:favoritesArray forKey:@"SortManagerPaths"];
		
		[favoritesArray release];
	}
}

@end
