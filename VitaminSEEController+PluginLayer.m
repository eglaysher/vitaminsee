/////////////////////////////////////////////////////////////////////////
// File:          $Name$
// Module:        Actual implementation of the methods in PluginLayer.
// Part of:       VitaminSEE
//
// Revision:      $Revision$
// Last edited:   $Date$
// Author:        $Author$
// Copyright:     (c) 2005 Elliot Glaysher
//
/////////////////////////////////////////////////////////////////////////
//
// This library is free software; you can redistribute it and/or
// modify it under the terms of the GNU Lesser General Public
// License as published by the Free Software Foundation; either
// version 2.1 of the License, or (at your option) any later version.
//  
// This library is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
// Lesser General Public License for more details.
//  
// You should have received a copy of the GNU Lesser General Public
// License along with this library; if not, write to the Free Software
// Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  
// USA
//
/////////////////////////////////////////////////////////////////////////

#import "PluginLayer.h"
#import "ViewIconViewController.h"
#import "ImageMetadata.h"
#import "ThumbnailManager.h"
#import "VitaminSEEController.h"
#import "VitaminSEEController+PluginLayer.h"

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
	[file retain];
	
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
	
	[file release];
	
	return tag;
}

-(int)moveFile:(NSString*)file to:(NSString*)destination
{
	[file retain];
	
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

	[file release];
	
	return tag;
}

-(int)copyFile:(NSString*)file to:(NSString*)destination
{
	// Retain file since we change the current file
	[file retain];
	
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

	// Release file
	[file release];
	
	return tag;
}

-(BOOL)renameFile:(NSString*)file to:(NSString*)destination
{
	// Retain file since we change the current file on success
	[file retain];
	
	// Rename the file.
	NSFileManager* fileManager = [NSFileManager defaultManager];
	NSString* destinationPath = [[file stringByDeletingLastPathComponent] 
		stringByAppendingPathComponent:destination];
	BOOL worked = NO;
	BOOL canUndo = YES;
	
	if([fileManager fileExistsAtPath:file])
	{
		// First, we test to see if there's a file that's going to be overwritten...
		if([fileManager fileExistsAtPath:destinationPath])
		{
			if(![self removeOverwriteFile:destinationPath])
				return 0;
			else
				canUndo = NO;
		}

		NSLog(@"Moving %@ to %@", file, destinationPath);
		worked = [[NSFileManager defaultManager] movePath:file
												   toPath:destinationPath 
												  handler:nil];

		if(worked)
		{
			[viewAsIconsController removeFile:file];
			[viewAsIconsController addFile:destinationPath];
			
			// fixme! file is often not of type NSString when undoing this!?
			
			if(canUndo)
			{
				[[self undoManager] setActionName:@"Rename"];
				NSString* originalFilename = [file lastPathComponent];
				[[[self undoManager] prepareWithInvocationTarget:self] 
					renameFile:destinationPath to:originalFilename];
			}
		}
		else
			AlertSoundPlay();
	}
	
	// Release the old current file
	[file release];

	return worked;
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
	[oldDestination retain];
	
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
	
	[oldDestination release];
	
	return worked;
}

-(BOOL)removeOverwriteFile:(NSString*)fileToOverwrite
{
	// Okay, so the file already exists. Let's ask the user for guidance
	NSString* format = NSLocalizedString(@"An item named '%@' already exists in the directory '%@'. This operation cannot be undone.", 
										 @"Warning message when user would overwrite a file");
	NSString* messageText = NSLocalizedString(@"Overwrite file?", 
		@"Warning message when user would overwrite a file");
	NSString* overwriteButton = NSLocalizedString(@"Overwrite", 
		@"Overwrite button in warning message");
	NSString* cancelButton = NSLocalizedString(@"Cancel",
		@"Overwrite button in warning message");
	
	NSString* text = [NSString stringWithFormat:format, [fileToOverwrite lastPathComponent], 
		[fileToOverwrite stringByDeletingLastPathComponent]];
	NSAlert* alert = [NSAlert alertWithMessageText:messageText
									 defaultButton:overwriteButton
								   alternateButton:cancelButton
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
