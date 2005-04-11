//
//  FavoritesMenuDelegate.m
//  VitaminSEE
//
//  Created by Elliot on 4/11/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "FavoritesMenuDelegate.h"
#import "VitaminSEEController.h"

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
	return [[[NSUserDefaults standardUserDefaults] objectForKey:@"SortManagerPaths"] count];
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

	// Enable this if the path exists
	[item setEnabled:[[d objectForKey:@"Path"] isDir]];
}

-(void)setDirectoryFromFavorites:(id)menu
{
	[controller finishedGotoFolder:[menu representedObject]];
}

@end
