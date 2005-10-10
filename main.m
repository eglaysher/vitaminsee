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
//	NSBundle* b = [NSBundle bundleWithPath:[[[NSBundle mainBundle] builtInPlugInsPath] stringByAppendingPathComponent:@"ViewIconsFileList.bundle"]];
//	NSLog(@"Bundle: %@", b);
//	[b load];
//	NSLog(@"Bundle: %@", b);
//	
//	NSLog(@"Principle: %@", [b principalClass]);
	
	
//	return 0;

	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];

	[ComponentManager scanDirectoryForPlugins:[[NSBundle mainBundle] builtInPlugInsPath]];
    [pool release];
	
	return NSApplicationMain(argc,  (const char **) argv);
}
