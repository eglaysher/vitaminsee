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

// Dictionaries of names to Internal Components
static NSMutableDictionary* internalComponents = 0;

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
	if(!internalComponents)
		internalComponents = [[NSMutableDictionary alloc] init];
	
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

				// More shit goes here. Fixme.
				[currentFilePlugins setObject:pluginInfo forKey:pluginName];
			}
			else if([pluginType isEqual:@"InternalUse"]) {
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

+(id)getInteranlComponentNamed:(NSString*)name
{
	BOOL firstTime;
	return [self returnPluginNamed:name
					fromDictionary:internalComponents
						  protocol:nil
						 firstTime:&firstTime];	
}


//-----------------------------------------------------------------------------

/** Private internal function used to 
 *
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
			NSLog(@"This component's principle class is %@", NSStringFromClass(principle));
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
