//
//  EGPath.m
//  VitaminSEE
//
//  Created by Elliot Glaysher on 5/2/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "EGPath.h"
#import "NSString+FileTasks.h"

#import <Cocoa/Cocoa.h>
#import <Carbon/Carbon.h>
#import <SystemConfiguration/SystemConfiguration.h>

@interface EGPath (Private)
-(NSArray*)buildEGPathArrayFromArrayOfNSStrings:(NSArray*)paths;
@end

// ----------------------------------------------------------------------------

@implementation EGPath

+(id)root
{
	return [EGPathRoot root];
}

+(id)pathWithPath:(NSString*)path
{
	return [EGPathFilesystemPath pathWithPath:path];
}

// ----- Comparator
-(NSComparisonResult)compare:(id)object
{
	return [[self fileSystemPath] compare:[object fileSystemPath]];
}

// ----- Methods that get overridden in subclasses

-(NSString*)displayName
{
	[self doesNotRecognizeSelector:_cmd];
	return nil;
}

-(NSArray*)directoryContents
{
	[self doesNotRecognizeSelector:_cmd];
	return nil;
}

-(NSString*)fileSystemPath
{
	[self doesNotRecognizeSelector:_cmd];
	return nil;
}

-(BOOL)isRoot
{
	return NO;
}

-(BOOL)exists
{
	[self doesNotRecognizeSelector:_cmd];
	return NO;
}

-(BOOL)isDirectory
{
	[self doesNotRecognizeSelector:_cmd];
	return NO;	
}

// The icon for the computer
-(NSImage*)fileIcon
{
	[self doesNotRecognizeSelector:_cmd];
	return nil;	
}

-(NSArray*)pathDisplayComponents
{
	[self doesNotRecognizeSelector:_cmd];
	return nil;	
}

-(NSArray*)pathComponents
{
	[self doesNotRecognizeSelector:_cmd];
	return nil;	
}

@end

@implementation EGPath (Private)

-(NSArray*)buildEGPathArrayFromArrayOfNSStrings:(NSArray*)paths
{
	NSEnumerator* e = [paths objectEnumerator];
	NSString* current;
	NSMutableArray* pathsToReturn = [NSMutableArray arrayWithCapacity:[paths count]];
	while(current = [e nextObject])
		[pathsToReturn addObject:[EGPath pathWithPath:current]];
	
	return pathsToReturn;
}

@end


// ----------------------------------------------------------------------------

@implementation EGPathRoot

+(id)root
{
	return [[[EGPathRoot alloc] init] autorelease];
}

-(NSString*)displayName
{
	// http://www.cocoadev.com/index.pl?HowToGetHardwareAndNetworkInfo
	CFStringRef name;
	NSString *computerName;
	name = SCDynamicStoreCopyComputerName(NULL,NULL);
	computerName = [NSString stringWithString:(NSString *)name];
	CFRelease(name);
	return computerName;
}

-(NSArray*)directoryContents
{
	NSArray* paths = [[NSWorkspace sharedWorkspace] mountedLocalVolumePaths];
//	NSLog(@"Computer paths: %@", paths);
	return [self buildEGPathArrayFromArrayOfNSStrings:paths];
}

-(BOOL)exists
{
	return YES;
}

-(BOOL)isRoot
{
	return YES;
}

-(BOOL)isDirectory
{
	return YES;
}

-(NSImage*)fileIcon
{
	return [NSImage imageNamed:@"iMac"];
}

-(NSArray*)pathDisplayComponents
{
	return [NSArray arrayWithObject:[self displayName]];
}

-(NSArray*)pathComponents
{
	return [NSArray arrayWithObject:[EGPathRoot root]];
}

@end

@implementation EGPathFilesystemPath

+(id)pathWithPath:(NSString*)path
{
	return [[[EGPathFilesystemPath alloc] initWithPath:path] autorelease];
}

-(id)initWithPath:(NSString*)path
{
	if(self = [super init])
		fileSystemPath = [[path stringByStandardizingPath] retain];
	
	return self;
}

-(void)dealloc
{
	[fileSystemPath release];
	[super dealloc];
}

// ----------------------------------------------------------------------------

-(NSString*)description
{
	return [NSString stringWithFormat:@"<EGPathFileSystemPath: %x: %@>", self, fileSystemPath];
}

// ----------------------------------------------------------------------------

-(NSString*)displayName
{
	if(![fileSystemPath isLink])
		return [[NSFileManager defaultManager] displayNameAtPath:fileSystemPath];
	else
	{
		NSLog(@"%@ is a link!", fileSystemPath);
		return [fileSystemPath lastPathComponent];
	}
}

-(NSArray*)directoryContents
{
	NSArray* childPaths = [[NSFileManager defaultManager] 
		directoryContentsAtPath:fileSystemPath];
	int count = [childPaths count];
	NSMutableArray* fullChildPaths = [NSMutableArray arrayWithCapacity:count];

	// Make sure these are full paths
	int i;
	for(i = 0; i < count; ++i)
	{
		NSString* fullPath = [fileSystemPath stringByAppendingPathComponent:
			[childPaths objectAtIndex:i]];
		[fullChildPaths addObject:fullPath];
		
		// wow, looks like somebody didn't test the retain/release functionality
		// in the standard library to well...
//		[childPaths replaceObjectAtIndex:i withObject:fullPath];
	}
	
	return [self buildEGPathArrayFromArrayOfNSStrings:fullChildPaths];
}

-(NSString*)fileSystemPath
{
	return fileSystemPath;
}

-(BOOL)exists
{
	return [[NSFileManager defaultManager] fileExistsAtPath:fileSystemPath];
}

-(BOOL)isDirectory
{
	BOOL exists, isDir;
	exists = [[NSFileManager defaultManager] fileExistsAtPath:fileSystemPath
												  isDirectory:&isDir];
	
	return exists && isDir;
}

-(NSImage*)fileIcon
{
	return [fileSystemPath iconImageOfSize:NSMakeSize(32,32)];	
}

-(NSArray*)pathDisplayComponents
{
	NSMutableArray* components = [[[[NSFileManager defaultManager] 
		componentsToDisplayForPath:fileSystemPath] mutableCopy] autorelease];
	[components insertObject:[[EGPathRoot root] displayName] atIndex:0];
	
	return components;
}

-(NSArray*)pathComponents
{
	NSMutableArray* mountedVolumes = [[NSWorkspace sharedWorkspace] mountedLocalVolumePaths];
	NSMutableArray* components = [NSMutableArray array];
	
	// Remove "/" from the array; it doesn't need any special handeling.
//	[mountedVolumes removeObject:[EGPathFilesystemPath pathWithPath:@"/"]];

	NSString* currentPath = fileSystemPath;
	
	// Start from the end of the path, chopping off each
	while(1)//![currentPath isEqual:@"/"])
	{
		// First add the current path to the list of paths we return
		[components insertObject:[EGPathFilesystemPath pathWithPath:currentPath]
						 atIndex:0];		
		
		// Now go through each mounted volume mount point. If there's a match,
		// then we need to break out of this loop.
		if([mountedVolumes containsObject:currentPath])
			break;
		
		// Remove the last component of currentPath
		currentPath = [currentPath stringByDeletingLastPathComponent];
	}
	
	// Finally, add the computer
	[components insertObject:[EGPathRoot root] atIndex:0];
	
	return components;
}

@end




