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

@implementation FavoritesMenuFactory

-(id)buildMenuDelegate
{
	return [[FavoritesMenuDelegate alloc] init];
}

-(id)buildToolbarItemWithIdentifier:(NSString*)itemIdent
{
	return [[FavoritesToolbarItem alloc] initWithItemIdentifier:itemIdent];
}

@end
