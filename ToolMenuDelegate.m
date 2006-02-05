/////////////////////////////////////////////////////////////////////////
// File:          $Name$
// Module:        Delegate object that displays the Tool menu.
// Part of:       VitaminSEE
//
// ID:            $Id: ApplicationController.m 123 2005-04-18 00:21:02Z elliot $
// Revision:      $Revision: 248 $
// Last edited:   $Date: 2005-07-13 20:26:59 -0500 (Wed, 13 Jul 2005) $
// Author:        $Author: elliot $
// Copyright:     (c) 2005 Elliot Glaysher
// Created:       1/13/05
//
/////////////////////////////////////////////////////////////////////////
//
// This program is free software; you can redistribute it and/or
// modify it under the terms of the GNU General Public License
// as published by the Free Software Foundation; either version 2
// of the License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program; if not, write to the Free Software
// Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
//
////////////////////////////////////////////////////////////////////////


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
