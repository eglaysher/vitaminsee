//
//  FavoritesToolbarItem.h
//  VitaminSEE
//
//  Created by Elliot on 4/9/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class MVMenuButton;
@class VitaminSEEController;
@class FavoritesMenuDelegate;

@interface FavoritesToolbarItem : NSToolbarItem {
	MVMenuButton* popUpImage;
	NSMenu* favoritesMenu;
	FavoritesMenuDelegate* favoritesMenuDelegate;
}

-(id)initWithItemIdentifier:(NSString*)itemIdent 
				 controller:(VitaminSEEController*)inCont;

@end
