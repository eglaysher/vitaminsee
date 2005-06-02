//
//  OpenWithMenuController.h
//  VitaminSEE
//
//  Created by Elliot Glaysher on 6/2/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "PluginBase.h"

@interface OpenWithMenuController : NSObject <PluginBase> {
	PluginLayer* pluginLayer;
}

-(id)buildMenuDelegate;

@end
