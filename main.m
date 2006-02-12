//
//  main.m
//  Prototype
//
//  Created by Elliot Glaysher on 8/5/05.
//  Copyright __MyCompanyName__ 2005. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "ComponentManager.h"

int main(int argc, char *argv[])
{
	// Load the list of plugins before we start the Application.
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];	
	[ComponentManager scanDirectoryForPlugins:[[NSBundle mainBundle] builtInPlugInsPath]];
    [pool release];
	
	return NSApplicationMain(argc,  (const char **) argv);
}
