/////////////////////////////////////////////////////////////////////////
// File:          $Name$
// Module:        PluginBase wrapper around my EGOpenWithMenuDelegate
// Part of:       VitaminSEE
//
// ID:            $Id: VitaminSEEController.m 123 2005-04-18 00:21:02Z elliot $
// Revision:      $Revision: 233 $
// Last edited:   $Date: 2005-06-04 21:33:37 -0400 (Sat, 04 Jun 2005) $
// Author:        $Author: glaysher $
// Copyright:     (c) 2005 Elliot Glaysher
// Created:       6/02/05
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

#import "OpenWithMenuController.h"
#import "EGOpenWithMenuDelegate.h"
#import "ApplicationController.h"
#import "EGPath.h"

@implementation OpenWithMenuController

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
	[[NSWorkspace sharedWorkspace] openFile:[[[ApplicationController controller] currentFile] fileSystemPath]
							withApplication:pathToApplication];
}

-(NSString*)currentFilePathForOpenWithMenuDelegate
{
	return [[[ApplicationController controller] currentFile] fileSystemPath];
}

-(BOOL)openWithMenuDelegate:(EGOpenWithMenuDelegate*)openWithMenu
			 shouldShowItem:(NSDictionary*)item
{
	return [[item objectForKey:@"Path"] rangeOfString:@"Preview.app"].location == NSNotFound;
}

@end
