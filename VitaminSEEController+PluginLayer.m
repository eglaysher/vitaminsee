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

@interface VitaminSEEController (PluginLayerPrivate)
-(BOOL)removeOverwriteFile:(NSString*)fileToOverwrite;
-(BOOL)unCopyFile:(NSString*)oldDestination from:(NSString*)oldSource;
@end

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
	int tag = 0;

	if([[NSFileManager defaultManager] fileExistsAtPath:file])
	{
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
	}
	
	return tag;
}

-(int)moveFile:(NSString*)file to:(NSString*)destination
{
	int tag = 0;
	BOOL worked = NO;
	BOOL canUndo = YES;
	NSString* sourceDirectory = [file stringByDeletingLastPathComponent];
	NSString* destinationPath = [destination stringByAppendingPathComponent:
		[file lastPathComponent]];
	NSFileManager* fileManager = [NSFileManager defaultManager];
	
	if(![destination isEqual:[file stringByDeletingLastPathComponent]] &&
	   [fileManager fileExistsAtPath:file])
	{
		// First, we test to see if there's a file that's going to be overwritten...
		if([fileManager fileExistsAtPath:destinationPath])
		{
			if(![self removeOverwriteFile:destinationPath])
				return 0;
			else
				canUndo = NO;
		}
		
		worked = [fileManager movePath:file
								toPath:destinationPath
							   handler:nil];
		
		// Remove the current file from 
		if(worked)
		{
			[viewAsIconsController removeFile:file];
			[viewAsIconsController addFile:destinationPath];

			// Register the converse of this operation if we can undo. Because
			// moving is reciporical, we don't need an unMove function.
			if(canUndo)
			{
				[[self undoManager] setActionName:@"Move"];
				[[[self undoManager] prepareWithInvocationTarget:self] 
					moveFile:destinationPath
						  to:sourceDirectory];
			}
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
	BOOL canUndo = YES;
	NSString* sourceDirectory = [file stringByDeletingLastPathComponent];
	NSString* destinationPath = [destination stringByAppendingPathComponent:
		[file lastPathComponent]];
	NSFileManager* fileManager = [NSFileManager defaultManager];
	
	if(![destination isEqual:[file stringByDeletingLastPathComponent]] &&
	   [fileManager fileExistsAtPath:file])
	{
		// First, we test to see if there's a file that's going to be overwritten...
		if([fileManager fileExistsAtPath:destinationPath])
		{
			if(![self removeOverwriteFile:destinationPath])
				return 0;
			else
				canUndo = NO;
		}
		
		worked = [fileManager copyPath:file
								toPath:destinationPath
							   handler:nil];
		
		// Calculate the destination name
		if(worked)
		{
			[viewAsIconsController addFile:destinationPath];
			
			if(canUndo)
			{
				[[self undoManager] setActionName:@"Copy"];
				[[[self undoManager] prepareWithInvocationTarget:self] 
					unCopyFile:destinationPath from:file];
			}
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

@implementation VitaminSEEController (PluginLayerPrivate)

-(BOOL)unCopyFile:(NSString*)oldDestination from:(NSString*)oldSource
{
	// Delete the oldSource
	// Reminder: Download that O-zone song.
	NSFileManager* fileManager = [NSFileManager defaultManager];
	BOOL worked = NO;
	
	if([fileManager fileExistsAtPath:oldDestination])
	{
		worked = [[NSFileManager defaultManager] removeFileAtPath:oldDestination
														  handler:nil];
	
		if(worked)
			[viewAsIconsController removeFile:oldDestination];
		else
			AlertSoundPlay();
	}
	else
		AlertSoundPlay();

	// If the source exists, we can undo this operation...
	if([fileManager fileExistsAtPath:oldSource])
	{
		[[self undoManager] setActionName:@"Copy"];
		[[[self undoManager] prepareWithInvocationTarget:self]
				copyFile:oldSource to:[oldDestination stringByDeletingLastPathComponent]];		
	}
	
	return worked;
}

-(BOOL)removeOverwriteFile:(NSString*)fileToOverwrite
{
	// Okay, so the file already exists. Let's ask the user for guidance
	NSString* text = [NSString stringWithFormat:
		@"A file named '%@' already exists in the directory '%@'. This operation cannot be undone.", 
		[fileToOverwrite lastPathComponent], 
		[fileToOverwrite stringByDeletingLastPathComponent]];
	NSAlert* alert = [NSAlert alertWithMessageText:@"Overwrite file?"
									 defaultButton:@"Overwrite"
								   alternateButton:@"Cancel"
									   otherButton:nil
						 informativeTextWithFormat:text];
	
	int result = [alert runModal];
	
	if(result ==  NSAlertDefaultReturn)
	{
		// Delete the offending file.
		[[NSFileManager defaultManager] removeFileAtPath:fileToOverwrite handler:nil];
		return YES;
	}
	else
		return NO;
}

@end
