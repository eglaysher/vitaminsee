/////////////////////////////////////////////////////////////////////////
// File:          $Name$
// Module:        Loads Components at runtime.
// Part of:       VitaminSEE
//
// ID:            $Id: ApplicationController.m 123 2005-04-18 00:21:02Z elliot $
// Revision:      $Revision: 248 $
// Last edited:   $Date: 2005-07-13 20:26:59 -0500 (Wed, 13 Jul 2005) $
// Author:        $Author: elliot $
// Copyright:     (c) 2005 Elliot Glaysher
// Created:       9/4/05
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
#import "FileList.h"
#import "CurrentFilePlugin.h"

// The ComponentManager keeps track of plugins that can be loaded. These plugins
// are scaned for at startup, but aren't actually loaded until needed.


// Each Plugin Bundle MUST define the following keys in its Info.plist file:
//
// <key>VSPluginType</key>
// <string>[FileList|CurrentFile|InternalUse]</string>
// <key>VSPluginName</key>
// <string>Plugin Name</string>
//
// For FileList plugins, the following must be defined:
// <key>VSFLMenuName</key>
// <string>as Icons</string>

// For CurrentFile plugins, the following must be defined:
// <key>VSCFMenuItems</key>
// <array>
//   <dict>
//     <key>Item</key>
//     <string>Picture Info</string>
//     <key>Location</key>
//     <string>Window</string>
//     <key>Action</key>
//     <string>pictureInfo:</string>
//   </dict>
//   [You may add as many menu items as you think you need]
// </array>

// InternalUse plugins signal plugins that I use to provide features of
// VitaminSEE. You can go ahead and mark your plugins as InteralUse, but they
// will just be ignored.

@interface ComponentManager : NSObject {
}

+(void)scanDirectoryForPlugins:(NSString*)path;

+(id<FileListFactory>)getFileListPluginNamed:(NSString*)name;
+(id<CurrentFilePlugin>)getCurrentFilePluginNamed:(NSString*)name;
+(id)getInteranlComponentNamed:(NSString*)name;

+(id)returnPluginNamed:(NSString*)name 
		fromDictionary:(NSDictionary*)dictionary
			  protocol:(Protocol*)protocol
			 firstTime:(BOOL*)firstTime;

+(NSArray*)getFileListsToDisplayInMenu;
+(NSArray*)getCurrentFilePluginsInViewMenu;

+(NSArray*)getLoadedCurrentFilePlugins;
@end
