//
//  ToolMenuDelegate.m
//  VitaminSEE
//
//  Created by Elliot on 1/13/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "ToolMenuDelegate.h"
#import "ComponentManager.h"
#import "EGPath.h"

@implementation ToolMenuDelegate

- (int)numberOfItemsInMenu:(NSMenu *)menu
{	
	int number =[[ComponentManager getCurrentFilePluginsInViewMenu] count];
//	NSLog(@"Number of items %d", number);
	return number;
}

- (BOOL)menu:(NSMenu *)menu
  updateItem:(NSMenuItem *)item 
	 atIndex:(int)index 
shouldCancel:(BOOL)shouldCancel
{
	NSArray* currentViews = [ComponentManager getCurrentFilePluginsInViewMenu];
	NSDictionary* pluginLine = [currentViews objectAtIndex:index];
	
	[item setTitle:[pluginLine objectForKey:@"Menu Name"]];
	[item setAction:@selector(sendPluginActivationSignal:)];
	[item setTarget:self];
	[item setRepresentedObject:pluginLine];
	return YES;
}	

-(void)sendPluginActivationSignal:(id)menuItem
{
	NSDictionary* pluginLine = [menuItem representedObject];
	NSWindow* mainWindow = [NSApp mainWindow];
	EGPath* mainFile = [[[mainWindow windowController] document] currentFile];
	
	NSLog(@"Plugin line: %@", pluginLine);
	NSString* name = [pluginLine objectForKey:@"Plugin Name"];
	NSLog(@"Name: %@", name);
	id component = [ComponentManager getCurrentFilePluginNamed:name];
	NSLog(@"Component: %@", component);
	
	[component
		activatePluginWithFile:mainFile
					  inWindow:mainWindow
					   context:pluginLine];
}

@end
