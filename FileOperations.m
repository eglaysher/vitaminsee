//
//  FileOperations.m
//  CQView
//
//  Created by Elliot on 2/13/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "FileOperations.h"

@implementation CQViewController (FileOperations)

-(int)deleteFile:(NSString*)file
{
	// We move the current file to the trash.
	int tag;
	[[NSWorkspace sharedWorkspace] performFileOperation:NSWorkspaceRecycleOperation
												 source:[file stringByDeletingLastPathComponent]
											destination:@""
												  files:[NSArray arrayWithObject:[file lastPathComponent]]
													tag:&tag];
	return tag;
}

-(int)moveFile:(NSString*)file to:(NSString*)destination
{
	// fixme: We need to select the next file in this directory!
	// fixme: Code organization: We should move all these file operations into
	//        a category...
	int tag;
	[[NSWorkspace sharedWorkspace] performFileOperation:NSWorkspaceMoveOperation
												 source:[file stringByDeletingLastPathComponent]
											destination:destination
												  files:[NSArray arrayWithObject:[file lastPathComponent]]
													tag:&tag];
	return tag;
}

-(int)copyFile:(NSString*)file to:(NSString*)destination
{
	int tag;
	[[NSWorkspace sharedWorkspace] performFileOperation:NSWorkspaceCopyOperation
												 source:[file stringByDeletingLastPathComponent]
											destination:destination
												  files:[NSArray arrayWithObject:[file lastPathComponent]]
													tag:&tag];
	return tag;
}

@end
