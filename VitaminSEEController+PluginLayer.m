//
//  PluginLayer.m
//  CQView
//
//  Created by Elliot on 2/24/05.
//  Copyright 2005 Elliot Glaysher. All rights reserved.
//

#import "PluginLayer.h"
#import "ViewIconViewController.h"
#import "ImageMetadata.h"
#import "ThumbnailManager.h"

@implementation VitaminSEEController (PluginLayer)

// I want to support keywords and comments in PNGs and GIFs, but that would
// require that I write a block of code with libpng and libgif to read and
// write those metadata blocks. Right now, there is no such program like exiv2

-(BOOL)supportsKeywords:(NSString*)file
{
	NSString* type = [[file pathExtension] uppercaseString];
	BOOL canKeyword = NO;
	if([type isEqualTo:@"JPG"] || [type isEqualTo:@"JPEG"])
		canKeyword = YES;
	
	return canKeyword;
}

-(NSMutableArray*)getKeywordsFromFile:(NSString*)file
{
	NSString* type = [[file pathExtension] uppercaseString];

	if([type isEqualTo:@"JPG"] || [type isEqualTo:@"JPEG"])
		return [[self imageMetadataPlugin] getKeywordsFromJPEGFile:file];	
//	else if([type isEqualTo:@"PNG"])
//		return [ImageMetadata getKeywordsFromPNGFile:file];
}

-(void)setKeywords:(NSArray*)keywords forFile:(NSString*)file
{
	[[self imageMetadataPlugin] setKeywords:keywords forJPEGFile:file];
}

-(NSString*)currentFile
{
	return currentImageFile;
}

-(int)deleteFile:(NSString*)file
{
	// We move the current file to the trash.
	BOOL worked;
	int tag;

	// fixme: check return value of -[NSWorkspace getFileSystemInfoForPath]'s isUnmountable
	// value
	
	worked = [[NSWorkspace sharedWorkspace] performFileOperation:NSWorkspaceRecycleOperation
												 source:[file stringByDeletingLastPathComponent]
											destination:@""
												  files:[NSArray arrayWithObject:[file lastPathComponent]]
													tag:&tag];

	if(worked)
	{
		[viewAsIconsController removeFile:currentImageFile];
	}
	else
		AlertSoundPlay();
	
	return tag;
}

-(int)moveFile:(NSString*)file to:(NSString*)destination
{
	int tag = 0;
	BOOL worked = NO;
	NSString* sourceDirectory = [file stringByDeletingLastPathComponent];
	if(![destination isEqual:[file stringByDeletingLastPathComponent]])
	{
		worked = [[NSWorkspace sharedWorkspace]
			performFileOperation:NSWorkspaceMoveOperation
						  source:sourceDirectory
					 destination:destination
						   files:[NSArray arrayWithObject:[file lastPathComponent]]
							 tag:&tag];

		// Remove the current file from 
		if(worked)
		{
			NSString* destinationFile = [destination 
				stringByAppendingPathComponent:[file lastPathComponent]];

			[viewAsIconsController removeFile:file];
			[viewAsIconsController addFile:destinationFile];
			[mainVitaminSeeWindow setViewsNeedDisplay:YES];
			
			[[[self undoManager] prepareWithInvocationTarget:self] 
				moveFile:destinationFile
					  to:sourceDirectory];
		}
		else
			AlertSoundPlay();
	}
	else
		AlertSoundPlay();
	
	return tag;
}

-(int)copyFile:(NSString*)file to:(NSString*)destination
{
	int tag = 0;
	BOOL worked = NO;
	if(![destination isEqual:[file stringByDeletingLastPathComponent]])
	{
		worked = [[NSWorkspace sharedWorkspace] 
			performFileOperation:NSWorkspaceCopyOperation
						  source:[file stringByDeletingLastPathComponent]
					 destination:destination 
						   files:[NSArray arrayWithObject:[file lastPathComponent]]
							 tag:&tag];
		
		// Calculate the destination name
		if(worked)
		{
			NSString* destinationFullPath = [destination stringByAppendingString:[file lastPathComponent]];
			[viewAsIconsController addFile:destinationFullPath];
		}
		else
			AlertSoundPlay();
	}
	return tag;
}

-(BOOL)renameFile:(NSString*)file to:(NSString*)destination
{
	// Rename the file.
	NSString* newPath = [[file stringByDeletingLastPathComponent] 
		stringByAppendingPathComponent:destination];
	
	BOOL ret = [[NSFileManager defaultManager] movePath:file
												 toPath:newPath 
												handler:nil];
	
	if(ret)
	{
		[viewAsIconsController removeFile:currentImageFile];
		[viewAsIconsController addFile:newPath];
	}
	else
		AlertSoundPlay();
}

-(void)generateThumbnailForFile:(NSString*)path
{
	BOOL buildThumbnails = [[[NSUserDefaults standardUserDefaults] objectForKey:@"GenerateThumbnails"] boolValue];
	[thumbnailManager setShouldBuildIcon:buildThumbnails];	
	[thumbnailManager buildThumbnail:path];
}

-(void)clearThumbnailQueue
{
	[thumbnailManager clearThumbnailQueue];
}

-(NSUndoManager*)pathManager
{
	return pathManager;
}

-(NSUndoManager*)undoManager
{
	return [mainVitaminSeeWindow undoManager];
}

@end
