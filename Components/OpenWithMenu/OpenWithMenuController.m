//
//  OpenWithMenuController.m
//  VitaminSEE
//
//  Created by Elliot Glaysher on 6/2/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "OpenWithMenuController.h"
#import "PluginLayer.h"
#import "EGOpenWithMenuDelegate.h"

@implementation OpenWithMenuController

-(id)initWithPluginLayer:(PluginLayer*)inPluginLayer
{
	if(self = [super init])
	{
		pluginLayer = [inPluginLayer retain];
	}
	
	return self;
}

-(void)dealloc
{
	[pluginLayer release];
	[super dealloc];
}

-(id)buildMenuDelegate
{
	id menuDelegate = [[[EGOpenWithMenuDelegate alloc] init] autorelease];
	[menuDelegate setDelegate:self];
	return menuDelegate;
}

// --------------------------------------------------------------------------

////////////////////////////// OPEN WITH MENU DELEGATE // fixme: Move into own 
// class in OpenWithMenu bundle sometime...
-(void)openWithMenuDelegate:(EGOpenWithMenuDelegate*)openWithMenu
		openCurrentFileWith:(NSString*)pathToApplication
{
	[[NSWorkspace sharedWorkspace] openFile:[pluginLayer currentFile]
							withApplication:pathToApplication];
}

-(NSString*)currentFilePathForOpenWithMenuDelegate
{
	return [pluginLayer currentFile];
}

-(BOOL)openWithMenuDelegate:(EGOpenWithMenuDelegate*)openWithMenu
			 shouldShowItem:(NSDictionary*)item
{
	return [[item objectForKey:@"Path"] rangeOfString:@"Preview.app"].location == NSNotFound;
}

@end
