//
//  ComponentManager.m
//  Prototype
//
//  Created by Elliot Glaysher on 9/4/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "ComponentManager.h"
#import "NSString+FileTasks.h"

// 
static int initialized = 0;

// Dictionaries of names to File List Plugins
static NSMutableDictionary* fileListPlugins = 0;

// Dictionaries of names to Current File Plugins
static NSMutableDictionary* currentFilePlugins = 0;

// Dictionaries of names to Internal Components
static NSMutableDictionary* internalComponents = 0;

// Dictionaries of View menu entries to names of FileListPlugins
static NSMutableArray* viewMenuNamesToBundleName = 0;

// Dictionaries of 
static NSMutableArray* viewMenuCurrentFilePluginsToBundleName = 0;

// PUBLIC INTERFACE
@implementation ComponentManager

//<key>VSPluginType</key>
//<string>FileList</string>
//<key>VSPluginName</key>
//<string>ViewAsIcons</string>
//<key>VSFLMenuName</key>
//<string>as Icons</string>

/** Builds the static components of this class. Guarenteed to be called before
 * any other method is called.
 */
+(void)initialize
{
	fileListPlugins = [[NSMutableDictionary alloc] init];	
	currentFilePlugins = [[NSMutableDictionary alloc] init];
	internalComponents = [[NSMutableDictionary alloc] init];
	viewMenuNamesToBundleName = [[NSMutableArray alloc] init];
	viewMenuCurrentFilePluginsToBundleName = [[NSMutableArray alloc] init];
}

/** Scans through the directory path, looking for ".bundle"s that are components
 * of VitaminSEE. We check the Info.plist of each Bundle, checking certain keys
 * so we have information on all the possible plugins that could be loaded at
 * runtime.
 *
 */
+(void)scanDirectoryForPlugins:(NSString*)path
{	
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
					pluginName, @"PluginName", 
					currentBundle, @"Bundle",
					@"FileList", @"PluginType", 
					menuName, @"MenuName",
					nil];
				
				// Add this FileList to the list of array of FileLists that will
				// be displayed in the View menu.
				[viewMenuNamesToBundleName addObject:
					[NSDictionary dictionaryWithObjectsAndKeys:
						menuName, @"MenuName",
						pluginName, @"PluginName", nil]];
				
				[fileListPlugins setObject:pluginInfo forKey:pluginName];
			}
			else if([pluginType isEqual:@"CurrentFile"]) {
				NSString* menuName = [info objectForKey:@"VSCFMenuName"];
				NSString* menuLocation = [info objectForKey:@"VSCFMenuItemLocation"];
				NSMutableDictionary* pluginInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:
					pluginName, @"PluginName", currentBundle, @"Bundle",
					@"CurrentFile", @"PluginType", 
					menuName, @"MenuItemName", menuLocation, @"MenuLocation",
					nil];

				// Add the plugin's menu entries to one of the various names
				//

				[currentFilePlugins setObject:pluginInfo forKey:pluginName];
			}
			else if([pluginType isEqual:@"InternalUse"]) {
				// The plugin equivalent of cheating.
				NSMutableDictionary* pluginInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:
					pluginName, @"PluginName", 
					@"Internal Use", @"PluginType",
					currentBundle, @"Bundle", nil];
				
				[internalComponents setObject:pluginInfo forKey:pluginName];
			}
			else {
				NSLog(@"WARNING! Ignoring bundle %@ since it has the invalid Bundle Type %@",
					  current, pluginType);
			}
		}
	}
	
	initialized = 1;
}

/** Gets a FileList, loading the bundle that contains it from disk if 
 * neccessary.
 *
 * @param name The name of the FileList
 * @return An instantiation of the FileList, which is owned by the 
 *         ComponentManager, and should not be released.
 */
+(id <FileListFactory>)getFileListPluginNamed:(NSString*)name
{
	BOOL firstTime;
	return [self returnPluginNamed:name
					fromDictionary:fileListPlugins
						  protocol:@protocol(FileListFactory)
						 firstTime:&firstTime];
}

//+(id<CurrentFilePlugin>)getCurrentFilePluginNamed:(NSString*)name
//{
//	if(!initialized)
//		return nil;
//		
//	// fixme
//	return nil;
//}

/** Gets a internal component (A piece of code that we cheated and stuck
 * in a plugin without defining some sort of formal interface).
 *
 * @param name The name of the component
 * @return An instantiation of the component, which is owned by the 
 *         ComponentManager, and should not be released.
 */
+(id)getInteranlComponentNamed:(NSString*)name
{
	BOOL firstTime;
	NSLog(@"Loading component %@", name);
	return [self returnPluginNamed:name
					fromDictionary:internalComponents
						  protocol:nil
						 firstTime:&firstTime];	
}

/** Returns the array of all FileLists loaded and unloaded for display in the
 * view menu.
 */
+(NSArray*)getFileListsToDisplayInMenu
{
	return viewMenuNamesToBundleName;
}

/** Returns the array of all CurrentFilePlugins that should be displayed in the
 * view menu.
 */
+(NSArray*)getCurrentFilePluginsInViewMenu
{
	return viewMenuCurrentFilePluginsToBundleName;
}

//-----------------------------------------------------------------------------

/** Private internal function used to lookup/load plugins. When the plugin has
 * already been loaded into memory, the plugin will be pulled from a dictionary,
 * and NO will be assigned to firstTime. When the requested plugin hasn't been
 * loaded yet, it will be loaded from disk and firstTime will be set to YES.
 *
 * @param name The key to lookup in the dictionary
 * @param dictionary A dictionary of string keys to plugin objects.
 * @param protocol A protocol to check the object against.
 * @param firstTime A pointer to a variable. It will set based on whether the
 *                  plugin had to be loaded from disk.
 * @return The plugin instance object, which is owned by the ComponentManager
 *         and should not be released.
 */
+(id)returnPluginNamed:(NSString*)name 
		fromDictionary:(NSDictionary*)dictionary
			  protocol:(Protocol*)protocol
			 firstTime:(BOOL*)firstTime
{
	if(!initialized)
		return nil;

	NSMutableDictionary* pluginInfo = [dictionary objectForKey:name];
	if(pluginInfo == nil) {
		NSLog(@"WARNING! Could not find component named %@", name);
		return nil;
	}
	
	// Check to see if there is already a root instance
	id instance = [pluginInfo objectForKey:@"Instance"];
	*firstTime = NO;
	if(instance == nil) 
	{
		NSBundle* bundle = [pluginInfo objectForKey:@"Bundle"];
		BOOL loaded = [bundle load];
		if(!loaded)
		{
			NSLog(@"WARNING! Couldn't load the bundle %@", bundle);
			return nil;
		}
		
		Class principle = [bundle principalClass];
		// Check to make sure this class conforms to whatever protocol we want
		// to check if we were asked to verify that it conforms to a protocol.
		if(protocol && ![principle conformsToProtocol:protocol]) {
			NSLog(@"WARNING! Component named '%@' claims to conform to '%@' but doesn't!",
				  [pluginInfo objectForKey:@"PluginName"],
				  [pluginInfo objectForKey:@"PluginType"]);
			NSLog(@"This component's principle class is %@", 
				  NSStringFromClass(principle));
			return nil;
		}
		
		NSLog(@"Class: %@", principle);
		// Create the instance
		instance = [[principle alloc] init];
		[pluginInfo setObject:instance forKey:@"Instance"];
		*firstTime = YES;
	}
	
	return instance;
}
@end
