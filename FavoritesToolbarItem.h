//
//  FavoritesToolbarItem.h
//  VitaminSEE
//
//  Created by Elliot on 4/9/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class PopUpImage;
@class VitaminSEEController;

@interface FavoritesToolbarItem : NSToolbarItem {
	PopUpImage* popUpImage;
	VitaminSEEController* controller;
}

-(id)initWithItemIdentifier:(NSString*)itemIdent 
				 controller:(VitaminSEEController*)inCont;

-(void)rebuildFavoritesMenu;

@end
