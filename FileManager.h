/*
 *  FileManager.h
 *  CQView
 *
 *  Created by Elliot on 2/22/05.
 *  Copyright 2005 Elliot Glaysher. All rights reserved.
 *
 */

#import <Cocoa/Cocoa.h>
#import "PluginBase.h"

@class VitaminSEEController;
@class PluginLayer;

@protocol FileManagerPlugin <PluginBase>

// File changed
-(void)fileSetTo:(NSString*)newPath;

// Get the plugin name
-(NSString*)name;

// Most plugins will have a show window
-(void)activate;

// Context menu items for this plugin.
-(NSArray*)contextMenuItems;

@end