//
//  VitaminSEEController+LoadableComponents.m
//  VitaminSEE
//
//  Created by Elliot Glaysher on 6/2/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "VitaminSEEController+LoadableComponents.h"
#import "PluginLayer.h"

#import "PluginBase.h"
#import "FileView.h"
#import "CurrentFilePlugin.h"

@implementation VitaminSEEController (LoadableComponents)

-(id)loadComponentNamed:(NSString*)name fromBundle:(NSString*)path
{
	NSParameterAssert(name);
	NSParameterAssert(path);
	
	NSString *bundlePath = [[[NSBundle mainBundle] builtInPlugInsPath]
			stringByAppendingPathComponent:path];
	NSBundle *windowBundle = [NSBundle bundleWithPath:bundlePath];	
	id component;
	
	if(windowBundle)
	{
		Class windowControllerClass = [windowBundle principalClass];
		if(windowControllerClass)
		{
			if([windowControllerClass conformsToProtocol:@protocol(CurrentFilePlugin)])
			{
				component = [[windowControllerClass alloc] initWithPluginLayer:
					[PluginLayer pluginLayerWithController:self]];
				[loadedCurrentFilePlugins setValue:component forKey:name];				
				[component fileSetTo:([mainVitaminSeeWindow isVisible] ? currentImageFile : nil )];
			}
			else if([windowControllerClass conformsToProtocol:@protocol(FileView)])
			{
				component = [[windowControllerClass alloc] initWithPluginLayer:
					[PluginLayer pluginLayerWithController:self]];
				[loadedViewPlugins setValue:component forKey:name];				
			}
			else if([windowControllerClass conformsToProtocol:@protocol(PluginBase)])
			{
				component = [[windowControllerClass alloc] initWithPluginLayer:
					[PluginLayer pluginLayerWithController:self]];
				[loadedBasePlugins setValue:component forKey:name];
			}
			else
				NSLog(@"WARNING! Attempt to load plugin from '%@' that doesn't conform to PluginBase! Plugin not loaded.",
					  path);
		}
		else
			NSLog(@"WARNING! Could not load principle class for plugin '%@'! Plugin not loaded.", name);
	}
	else
		NSLog(@"WARNING! Could not find plugin '%@' from internal plugin path '%@'! Plugin not loaded.", 
			  name, bundlePath);
	
	return component;
}

- (id) pluginNamed:(NSString*)pluginName
	  withFileName:(NSString*)pluginFileName
 inPluginDirectory:(id)pluginDirectory
{
	NSParameterAssert(pluginName);
	NSParameterAssert(pluginFileName);
	NSParameterAssert(pluginDirectory);
	
	id plugin = [pluginDirectory objectForKey:pluginName];
	if(!plugin)
		plugin = [self loadComponentNamed:pluginName fromBundle:pluginFileName];
	
	return plugin;
}

-(id)sortManagerController
{
	return [self pluginNamed:@"SortManagerController"
				withFileName:@"SortManager.cqvPlugin"
		   inPluginDirectory:loadedCurrentFilePlugins];
}

-(id)keywordManagerController
{
	return [self pluginNamed:@"KeywordManagerController"
				withFileName:@"KeywordManager.cqvPlugin"
		   inPluginDirectory:loadedCurrentFilePlugins];
}

-(id)gotoFolderController
{
	return [self pluginNamed:@"GotoFolderController"
				withFileName:@"GotoFolderSheet.bundle"
		   inPluginDirectory:loadedBasePlugins];
}

-(id)desktopBackgroundController
{
	return [self pluginNamed:@"DesktopBackgroundController"
				withFileName:@"DesktopBackground.bundle"
		   inPluginDirectory:loadedBasePlugins];
}

-(id)openWithMenuController
{
	return [self pluginNamed:@"OpenWithMenuController"
				withFileName:@"OpenWithMenu.bundle"
		   inPluginDirectory:loadedBasePlugins];
}

-(id)viewAsIconsControllerPlugin
{	
	return [self pluginNamed:@"ViewAsIconsController" 
				withFileName:@"ViewAsIconsFileView.bundle"
		   inPluginDirectory:loadedViewPlugins];
}

-(id)imageMetadataPlugin
{
	return [self pluginNamed:@"ImageMetadata"
				withFileName:@"ImageMetadata.bundle"
		   inPluginDirectory:loadedBasePlugins];
}

-(id)ssPrefsController
{
	return [self pluginNamed:@"SSPrefsController"
				withFileName:@"SSPrefsController.bundle"
		   inPluginDirectory:loadedBasePlugins];
}

@end
