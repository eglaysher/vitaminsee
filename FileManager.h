/*
 *  FileManager.h
 *  CQView
 *
 *  Created by Elliot on 2/22/05.
 *  Copyright 2005 __MyCompanyName__. All rights reserved.
 *
 */

#import <Cocoa/Cocoa.h>

@protocol FileManagerPlugin

// Most 
-(void)showWindow;

// File Manager Plugins can optionally put 
-(NSArray*)contextMenuItems;

@end