//
//  FavoritesMenuDelegate.h
//  VitaminSEE
//
//  Created by Elliot on 4/11/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class VitaminSEEController;

@interface FavoritesMenuDelegate : NSObject {
		VitaminSEEController* controller;
}

-(id)initWithController:(VitaminSEEController*)controller;

- (int)numberOfItemsInMenu:(NSMenu *)menu;

- (BOOL)menu:(NSMenu *)menu 
  updateItem:(NSMenuItem *)item 
	 atIndex:(int)index 
shouldCancel:(BOOL)shouldCancel;

@end
