//
//  ComponentManager.h
//  Prototype
//
//  Created by Elliot Glaysher on 9/4/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "FileList.h"

// The ComponentManager keeps track of plugins that can be loaded. These plugins
// are scaned for at startup, but aren't actually loaded until needed.


// Each Plugin Bundle MUST define the following keys in its Info.plist file:
//
// <key>VSPluginType</key>
// <string>[FileList|CurrentFile]</string>
// <key>VSPluginName</key>
// <string>Plugin Name</string>
//
// For FileList plugins, the following must be defined:
// <key>VSFLMenuName</key>
// <string>as Icons</string>

//View As Icons…</VSFLMenuName>
//
// For CurrentFile plugins, the following must be defined:
// <key>VSCFMenuItems</key>
// <array>
//   <dict>
//     <key>Item</key>
//     <string>Picture Info</string>
//     <key>Location</key>
//     <string>Window</string>
//   </dict>
//   [You may add as many menu items as you think you need]
// </array>


@interface ComponentManager : NSObject {
}

+(void)scanDirectoryForPlugins:(NSString*)path;

+(id<FileListFactory>)getFileListPluginNamed:(NSString*)name;
//+(id<CurrentFilePlugin>)getCurrentFilePluginNamed:(NSString*)name;

@end
