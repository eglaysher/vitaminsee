//
//  ToolbarDelegate.h
//  CQView
//
//  Created by Elliot on 1/30/05.
//  Copyright 2005 Elliot Glaysher. All rights reserved.
//

#import "VitaminSEEController.h"

@interface VitaminSEEController (ToolbarDelegate)

-(void)setupToolbar;

- (NSToolbarItem *) toolbar: (NSToolbar *)toolbar
	  itemForItemIdentifier: (NSString *) itemIdent 
  willBeInsertedIntoToolbar:(BOOL) willBeInserted;

- (NSArray *) toolbarDefaultItemIdentifiers: (NSToolbar *) toolbar;
- (NSArray *) toolbarAllowedItemIdentifiers: (NSToolbar *) toolbar;
@end
