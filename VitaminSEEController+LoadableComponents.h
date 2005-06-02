//
//  VitaminSEEController+LoadableComponents.h
//  VitaminSEE
//
//  Created by Elliot Glaysher on 6/2/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "VitaminSEEController.h"

@interface VitaminSEEController (LoadableComponents)

-(id)loadComponentNamed:(NSString*)name fromBundle:(NSString*)path;
-(id)pluginNamed:(NSString*)pluginName withFileName:(NSString*)pluginFileName
inPluginDirectory:(id)pluginDirectory;
-(id)sortManagerController;
-(id)keywordManagerController;
-(id)gotoFolderController;
-(id)desktopBackgroundController;
-(id)openWithMenuController;
-(id)viewAsIconsControllerPlugin;
-(id)imageMetadataPlugin;
-(id)ssPrefsController;

@end
