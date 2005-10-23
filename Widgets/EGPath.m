/////////////////////////////////////////////////////////////////////////
// File:          $Name$
// Module:        Path abstractions
// Part of:       VitaminSEE
//
// Revision:      $Revision: 192 $
// Last edited:   $Date: 2005-05-18 01:07:24 -0400 (Wed, 18 May 2005) $
// Author:        $Author: glaysher $
// Copyright:     (c) 2005 Elliot Glaysher
// Created:       5/2/05
//
/////////////////////////////////////////////////////////////////////////
//
// This program is free software; you can redistribute it and/or
// modify it under the terms of the GNU General Public License
// as published by the Free Software Foundation; either version 2
// of the License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program; if not, write to the Free Software
// Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
//
////////////////////////////////////////////////////////////////////////

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

-(id)copyWithZone:(NSZone*)zone
{
	// Implement for real in subclasses
	return nil;
}

+(id)root
{
	return [EGPathRoot root];
}

+(id)pathWithPath:(NSString*)path
{
	return [EGPathFilesystemPath pathWithPath:path];
}

-(NSData*)dataRepresentationOfPath
{
	return nil;
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

-(NSString*)fileName
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
	NSMutableArray* pathsToReturn = [NSMutableArray arrayWithCapacity:[paths count]];
	int i = 0, count = [paths count];
	for(; i < count; ++i)
	{
		id current = (id)CFArrayGetValueAtIndex((CFArrayRef)paths, i);
		[pathsToReturn addObject:[EGPath pathWithPath:current]];		
	}
	
	return pathsToReturn;
}

@end


// ----------------------------------------------------------------------------

static NSString* egPathRootDisplayName = 0;

@implementation EGPathRoot

-(id)copyWithZone:(NSZone*)zone
{
	return [[EGPathRoot allocWithZone:zone] init];
}

+(id)root
{
	return [[[EGPathRoot alloc] init] autorelease];
}

-(NSString*)displayName
{
	if(!egPathRootDisplayName)
	{
		CFStringRef name;
		// Okay, that failed. Let's ask Carbon for our name instead:
		name = CSCopyMachineName();
		if(name)
		{
			egPathRootDisplayName = [[NSString alloc] initWithString:(NSString *)name];
			CFRelease(name);
		}
		else
			// Screw it. Use a likely default...
			egPathRootDisplayName = [[NSString alloc] initWithString:@"Macintosh"];
	}
	
	return egPathRootDisplayName;
}

-(BOOL)isEqual:(id)rhs
{
	return [rhs isKindOfClass:[EGPathRoot class]];
}

-(NSArray*)directoryContents
{
	NSArray* paths = [[NSWorkspace sharedWorkspace] mountedLocalVolumePaths];
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

-(id)copyWithZone:(NSZone*)zone
{
	return [[EGPathFilesystemPath allocWithZone:zone] initWithPath:fileSystemPath];
}

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

-(BOOL)isEqual:(id)rhs
{
	return [rhs isKindOfClass:[EGPathFilesystemPath class]] && 
		[[rhs fileSystemPath] isEqualToString:fileSystemPath];
}

-(NSData*)dataRepresentationOfPath
{
	return [[NSData alloc] initWithContentsOfFile:fileSystemPath];
}

// ----------------------------------------------------------------------------

-(NSString*)description
{
	return [NSString stringWithFormat:@"<EGPathFileSystemPath: 0x%08x: %@>", self, fileSystemPath];
}

// ----------------------------------------------------------------------------

-(NSString*)displayName
{
	if([fileSystemPath isLink])
		return [fileSystemPath lastPathComponent];
	else
		return [[NSFileManager defaultManager] displayNameAtPath:fileSystemPath];
}

-(NSArray*)directoryContents
{
//	NSLog(@"-[EGPathFilesystemPath directoryContents]");
	
	NSArray* childPaths = [[NSFileManager defaultManager] 
		directoryContentsAtPath:fileSystemPath];
	int count = [childPaths count];
	NSMutableArray* fullChildPaths = [NSMutableArray arrayWithCapacity:count];

	// Make sure these are full paths
	int i;
	for(i = 0; i < count; ++i)
	{
		NSString* fullPath = [fileSystemPath stringByAppendingPathComponent:
			(id)CFArrayGetValueAtIndex((CFArrayRef)childPaths, i)];

		[fullChildPaths addObject:fullPath];		
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
	NSArray* pathComponents = [self pathComponents];
	NSMutableArray* displayComponents = [NSMutableArray array];
	int i = 0, count = [pathComponents count];
	for(; i < count; ++i)
	{
		id current = (id)CFArrayGetValueAtIndex((CFArrayRef)pathComponents, i);
		[displayComponents addObject:[current displayName]];
	}		
	
	return displayComponents;
}

-(NSArray*)pathComponents
{
	NSMutableArray* mountedVolumes = [[NSWorkspace sharedWorkspace] mountedLocalVolumePaths];
	NSMutableArray* components = [NSMutableArray array];	

	NSString* currentPath = fileSystemPath;
	
	// Start from the end of the path, chopping off each
	while(1)
	{
		// First add the current path to the list of paths we return
		[components insertObject:[EGPathFilesystemPath pathWithPath:currentPath]
						 atIndex:0];		
		
		// Now go through each mounted volume mount point. If there's a match,
		// then we need to break out of this loop. Considering that / will always
		// be mounted, this will break out when we hit root...
		if([mountedVolumes containsObject:currentPath])
			break;
		
		// Remove the last component of currentPath
		currentPath = [currentPath stringByDeletingLastPathComponent];
	}
	
	// Finally, add the computer
	[components insertObject:[EGPathRoot root] atIndex:0];

//	NSLog(@"Path Components: %@", components);
	
	return components;
}

-(NSComparisonResult)caseInsensitiveCompare:(id)rhs
{
	return [fileSystemPath caseInsensitiveCompare:rhs];
}

@end




