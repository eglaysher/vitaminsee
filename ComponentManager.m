//
//  ComponentManager.m
//  Prototype
//
//  Created by Elliot Glaysher on 9/4/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "ComponentManager.h"
#import "NSString+FileTasks.h"


#include <mach-o/dyld.h>
#include <mach/mach.h>

// 
static int initialized = 0;

// Dictionaries of names to File List Plugins
static NSMutableDictionary* fileListPlugins = 0;

// Dictionaries of names to Current File Plugins
static NSMutableDictionary* currentFilePlugins = 0;

// PUBLIC INTERFACE
@implementation ComponentManager

//<key>VSPluginType</key>
//<string>FileList</string>
//<key>VSPluginName</key>
//<string>ViewAsIcons</string>
//<key>VSFLMenuName</key>
//<string>as Icons</string>


+(void)scanDirectoryForPlugins:(NSString*)path
{
	// First, make sure we have somewhere in memory to stick our plugins
	if(!fileListPlugins)
		fileListPlugins = [[NSMutableDictionary alloc] init];
	if(!currentFilePlugins)
		currentFilePlugins = [[NSMutableDictionary alloc] init];
	
	// Look for all paths in the directory "path" that have the suffix ".bundle"
	NSArray* itemsInPath = [[NSFileManager defaultManager] 
		directoryContentsAtPath:path];
	int i, count = [itemsInPath count];
	for(i = 0; i < count; ++i) 
	{
		NSString* fileName = [itemsInPath objectAtIndex:i];
		NSString* current = [path stringByAppendingPathComponent:fileName];
		
		if([[current pathExtension] isEqual:@"bundle"] && [current isDir]) {
			NSBundle* currentBundle = [NSBundle bundleWithPath:current];
			NSDictionary* info = [currentBundle infoDictionary];
			NSString* pluginName = [info objectForKey:@"VSPluginName"];
			NSString* pluginType = [info objectForKey:@"VSPluginType"];
			
			if([pluginType isEqual:@"FileList"]) {
				NSString* menuName = [info objectForKey:@"VSFLMenuName"];
				NSMutableDictionary* pluginInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:
					pluginName, @"PluginName", currentBundle, @"Bundle",
					menuName, @"MenuName", [NSNumber numberWithBool:NO], @"Loaded", 
					nil];
								
				[fileListPlugins setObject:pluginInfo forKey:pluginName];
			}
			else if([pluginType isEqual:@"CurrentFile"]) {
				NSString* menuName = [info objectForKey:@"VSCFMenuName"];
				NSString* menuLocation = [info objectForKey:@"VSCFMenuItemLocation"];
				NSMutableDictionary* pluginInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:
					pluginName, @"PluginName", currentBundle, @"Bundle",
					menuName, @"MenuItemName", menuLocation, @"MenuLocation",
					[NSNumber numberWithBool:NO], @"Loaded", 
					nil];

				// More shit goes here. Fixme.
				[currentFilePlugins setObject:pluginInfo forKey:pluginName];
			}
			else {
				NSLog(@"WARNING! Could not load bundle %@ since it has the invalid Bundle Type %@",
					  current, pluginType);
			}
		}
	}
	
	initialized = 1;
}

+(id <FileListFactory>)getFileListPluginNamed:(NSString*)name
{
	if(!initialized)
		return nil;
	
	NSMutableDictionary* pluginInfo = [fileListPlugins objectForKey:name];
	if(pluginInfo == nil) {
		NSLog(@"WARNING! Could not find component named %@", name);
		return nil;
	}
	
	// Check to see if there is already a root instance
	id <FileListFactory> factory = [pluginInfo objectForKey:@"Instance"];
	if(factory == nil) 
	{
		NSBundle* bundle = [pluginInfo objectForKey:@"Bundle"];
		BOOL load = [bundle load];

		NSLog(@"Bundle: %@, %d" , bundle, load);

//		NSLinkEditErrors editError;
//		int errorNumber;
//		const char *name, *msg, *objFileImageErrMsg = NULL;
//		
//		NSLinkEditError(&editError, &errorNumber, &name, &msg);
//
//		NSLog(@"Error number %d, %d, %s, %s", editError, errorNumber, name, msg);

		Class principle = [bundle principalClass];
		if(![principle conformsToProtocol:@protocol(FileListFactory)]) {
			NSLog(@"WARNING! Component named %@ claims to conform to FileListPlugin but doesn't!",
				  [pluginInfo objectForKey:@"PluginName"]);
			NSLog(@"This component's principle class is %@", NSStringFromClass(principle));
			return nil;
		}
		
		// Create the instance
		factory = [[principle alloc] init];
		[pluginInfo setObject:factory forKey:@"Instance"];
	}

	return factory;
}

//+(id<CurrentFilePlugin>)getCurrentFilePluginNamed:(NSString*)name
//{
//	if(!initialized)
//		return nil;
//		
//	// fixme
//	return nil;
//}

@end
