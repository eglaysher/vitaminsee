//
//  PluginLayer.m
//  CQView
//
//  Created by Elliot on 2/24/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "PluginLayer.h"
#import "ViewIconViewController.h"
#import "ImageMetadata.h"

@implementation CQViewController (PluginLayer)

-(NSMutableArray*)getKeywordsFromFile:(NSString*)file
{
	return [ImageMetadata getKeywordsFromFile:file];
}

-(void)setKeywords:(NSArray*)keywords forFile:(NSString*)file
{
	[ImageMetadata setKeywords:keywords forFile:file];
	// fixme:
}

-(void)deleteThisFile
{
	// Delete the current file...
	[self deleteFile:currentImageFile];
	
	// fixme: Functionate/refactor this.
	NSString* nextFile = [viewAsIconsController nameOfNextFile];
	[viewAsIconsController removeFileFromList:currentImageFile];
	[viewAsIconsController selectFile:nextFile];
	
	[self setCurrentFile:nextFile];
}

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

-(void)moveThisFile:(NSString*)destination
{
	if(![destination isEqual:currentDirectory])
	{
		NSString* nextFile = [viewAsIconsController nameOfNextFile];
		[self moveFile:currentImageFile to:destination];
		[viewAsIconsController removeFileFromList:currentImageFile];
		[viewAsIconsController selectFile:nextFile];
		
		[self setCurrentFile:nextFile];
	}
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

-(void)copyThisFile:(NSString*)destination
{
	if(![destination isEqual:currentDirectory])
		[self copyFile:currentImageFile to:destination];
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
