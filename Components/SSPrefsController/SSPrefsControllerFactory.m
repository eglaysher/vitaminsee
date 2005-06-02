//
//  SSPrefsControllerFactory.m
//  VitaminSEE
//
//  Created by Elliot Glaysher on 6/2/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "SSPrefsControllerFactory.h"

#import "SS_PrefsController.h"

@implementation SSPrefsControllerFactory

-(id)initWithPluginLayer:(PluginLayer*)inPluginLayer
{
	return [super init];
}

-(id)buildWithPanesSearchPath:(NSString*)path bundleExtension:(NSString*)ext
{
	return [[[SS_PrefsController alloc] initWithPanesSearchPath:path
												bundleExtension:ext] autorelease];
}

@end
