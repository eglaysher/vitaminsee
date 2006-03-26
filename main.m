//
//  main.m
//  Prototype
//
//  Created by Elliot Glaysher on 8/5/05.
//  Copyright __MyCompanyName__ 2005. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "ComponentManager.h"

BOOL g_inSenTest;

int main(int argc, char *argv[])
{
	// Load the list of plugins before we start the Application.
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];	
	[ComponentManager scanDirectoryForPlugins:[[NSBundle mainBundle] builtInPlugInsPath]];
    [pool release];
	
	// Detect if we are being run in the OCUnit unit testing framework, and mark
	// if we are, so we don't bring up a ViewerWindow.
	g_inSenTest = NO;
	int i;
	for(i = 0; i < argc; ++i) {
		if(strcmp(argv[i], "-SenTest") == 0) {
			NSLog(@"------------ SenTest DETECTED ---------------");
			g_inSenTest = YES;
			break;
		}
	}
	
	return NSApplicationMain(argc,  (const char **) argv);
}
