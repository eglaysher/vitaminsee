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
		return [ImageMetadata getKeywordsFromJPEGFile:file];	
//	else if([type isEqualTo:@"PNG"])
//		return [ImageMetadata getKeywordsFromPNGFile:file];
}

-(void)setKeywords:(NSArray*)keywords forFile:(NSString*)file
{
	[ImageMetadata setKeywords:keywords forJPEGFile:file];
}

-(NSString*)currentFile
{
	return currentImageFile;
}

-(BOOL)renameThisFileTo:(NSString*)newName
{
	// Rename the file.
	NSString* newPath = [[currentImageFile stringByDeletingLastPathComponent] 
		stringByAppendingPathComponent:newName];
	
	BOOL ret = [[NSFileManager defaultManager] movePath:currentImageFile
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

-(void)deleteThisFile
{
	// Delete the current file...
	[self deleteFile:currentImageFile];
}

-(int)deleteFile:(NSString*)file
{
	// We move the current file to the trash.
	BOOL worked;
	int tag;

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

-(void)moveThisFile:(NSString*)destination
{
	[self moveFile:currentImageFile to:destination];
}

-(int)moveFile:(NSString*)file to:(NSString*)destination
{
	int tag = 0;
	BOOL worked = NO;
	if(![destination isEqual:[file stringByDeletingLastPathComponent]])
	{
		worked = [[NSWorkspace sharedWorkspace]
			performFileOperation:NSWorkspaceMoveOperation
						  source:[file stringByDeletingLastPathComponent]
					 destination:destination
						   files:[NSArray arrayWithObject:[file lastPathComponent]]
							 tag:&tag];

		// Remove the current file from 
		if(worked)
		{
			[viewAsIconsController removeFile:currentImageFile];
		}
		else
			AlertSoundPlay();
	}
	return tag;
}

-(void)copyThisFile:(NSString*)destination
{
	[self copyFile:currentImageFile to:destination];
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

-(void)generateThumbnailFor:(NSString*)path
{
	[thumbnailManager buildThumbnail:path];
}

@end
