//
//  FavoritesMenuFactory.m
//  VitaminSEE
//
//  Created by Elliot Glaysher on 10/23/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

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
