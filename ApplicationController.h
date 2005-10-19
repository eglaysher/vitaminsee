/////////////////////////////////////////////////////////////////////////
// File:          $Name$
// Module:        Main Controller Class
// Part of:       VitaminSEE
//
// Revision:      $Revision: 230 $
// Last edited:   $Date: 2005-06-02 16:03:06 -0500 (Thu, 02 Jun 2005) $
// Author:        $Author: glaysher $
// Copyright:     (c) 2005 Elliot Glaysher
// Created:       1/30/05
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


#import <Cocoa/Cocoa.h>

@class RBSplitView;
@class EGPath;

/*!
	@class ApplicationController
	@abstract Main Controller
*/
@interface ApplicationController : NSObject
{
	IBOutlet NSWindow* mainVitaminSeeWindow;
	
	// Menu items we need to attatch items to
	IBOutlet NSMenuItem* computerFolderMenuItem;
	IBOutlet NSMenuItem* homeFolderMenuItem;
	IBOutlet NSMenuItem* pictureFolderMenuItem;
	IBOutlet NSMenuItem* favoritesMenuItem;
//	FavoritesMenuDelegate* favoritesMenuDelegate;
	IBOutlet NSMenuItem* openWithMenuItem;

	// Open With Menu that needs initialization
//	EGOpenWithMenuDelegate* openWithMenuDelegate;
	BOOL loadedOpenWithMenu;

	NSMutableArray* pictureViewers;
	
//	SS_PrefsController *prefs;	
	
	// Loaded plugins:
	NSMutableDictionary* loadedBasePlugins;
	NSMutableDictionary* loadedViewPlugins;
	NSMutableDictionary* loadedCurrentFilePlugins;

	NSString* tmpDestination;

	BOOL setPathForFirstTime;
	
	int nextDocumentID;
}

-(NSNumber*)getNextAvailableID;

+(ApplicationController*)controller;

-(IBAction)newWindow:(id)sender;

-(void)goToDirectory:(EGPath*)path;
@end
