//
//  FileOperations.m
//  VitaminSEE
//
//  Created by Elliot on 1/16/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "FileOperations.h"
#import "EGPath.h"
#import "NSString+FileTasks.h"

@interface FileOperations (UndoCategory)
-(BOOL)unCopyFile:(NSString*)oldDestination from:(NSString*)oldSource;
-(BOOL)removeOverwriteFile:(NSString*)fileToOverwrite;
-(NSUndoManager*)undoManager;
@end

// ----------------------------------------------------------------------------

@implementation FileOperations

-(int)deleteFile:(EGPath*)path
{
	if([path isNaturalFile]) {
		AlertSoundPlay();
		return -1;
	}
	
	NSString* file = [path fileSystemPath];
	[file retain];
	
	// We move the current file to the trash.
	BOOL worked;
	int tag = 0;
	
	if([[NSFileManager defaultManager] fileExistsAtPath:file])
	{
		// fixme: check return value of -[NSWorkspace getFileSystemInfoForPath]'s isUnmountable
		// value
		
		worked = [[NSWorkspace sharedWorkspace] 
			performFileOperation:NSWorkspaceRecycleOperation
						  source:[file stringByDeletingLastPathComponent]
					 destination:@""
						   files:[NSArray arrayWithObject:
							   [file lastPathComponent]]
							 tag:&tag];
		
		if(worked)	
		{
//			[viewAsIconsController removeFile:currentImageFile];
		}
		else
			AlertSoundPlay();
	}
	
	[file release];
	
	return tag;
}

-(int)moveFile:(EGPath*)inFile to:(EGPath*)inDestination
{
	NSLog(@"%@ => %@", inFile, inDestination);
	if(![inFile isNaturalFile] || ![inDestination isNaturalFile]) {
		AlertSoundPlay();
		return -1;
	}
	NSString* file = [[inFile fileSystemPath] retain];
	NSString* destination = [inDestination fileSystemPath];
	
	int tag = 0;
	BOOL worked = NO;
	BOOL canUndo = YES;
//	NSString* sourceDirectory = [file stringByDeletingLastPathComponent];
	NSString* destinationPath = [destination stringByAppendingPathComponent:
		[file lastPathComponent]];
	NSFileManager* fileManager = [NSFileManager defaultManager];
	
	if([destination caseInsensitiveCompare:
		[file stringByDeletingLastPathComponent]] != NSOrderedSame &&
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
			// Register the converse of this operation if we can undo. Because
			// moving is reciporical, we don't need an unMove function.
			if(canUndo)
			{
				[[self undoManager] setActionName:NSLocalizedString(@"Move", @"Move undo label")];
				[[[self undoManager] prepareWithInvocationTarget:self] 
					moveFile:[EGPath pathWithPath:destinationPath]
						  to:[EGPath pathWithPath:[file stringByDeletingLastPathComponent]]];
			}
		}
		else
			AlertSoundPlay();
	}
	else {
		AlertSoundPlay();
		NSLog(@"Failed at first!");
	}
	
	[file release];
	
	return tag;
}

-(int)copyFile:(EGPath*)inFile to:(EGPath*)inDestination
{
	if(![inFile isNaturalFile] || ![inDestination isNaturalFile]) {
		AlertSoundPlay();
		return -1;
	}
	NSString* file = [[inFile fileSystemPath] retain];
	NSString* destination = [inDestination fileSystemPath];
	
	int tag = 0;
	BOOL worked = NO;
	BOOL canUndo = YES;
	//	NSString* sourceDirectory = [file stringByDeletingLastPathComponent];
	NSString* destinationPath = [destination stringByAppendingPathComponent:
		[file lastPathComponent]];
	NSFileManager* fileManager = [NSFileManager defaultManager];
	
	if([destination caseInsensitiveCompare:[file stringByDeletingLastPathComponent]] != NSOrderedSame &&
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
//			[viewAsIconsController addFile:destinationPath];
			
			if(canUndo)
			{
				[[self undoManager] setActionName:NSLocalizedString(@"Copy", @"Copy undo label")];
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

-(BOOL)renameFile:(EGPath*)inFile to:(EGPath*)inDestination
{
	if(![inFile isNaturalFile] || ![inDestination isNaturalFile]) {
		AlertSoundPlay();
		return -1;
	}
	NSString* file = [[inFile fileSystemPath] retain];
	NSString* destination = [inDestination fileSystemPath];
	
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
		
		//		NSLog(@"Moving %@ to %@", file, destinationPath);
		worked = [[NSFileManager defaultManager] movePath:file
												   toPath:destinationPath 
												  handler:nil];
		
		if(worked)
		{
//			[viewAsIconsController removeFile:file];
//			[viewAsIconsController addFile:destinationPath];
			
			// fixme! file is often not of type NSString when undoing this!?
			
			if(canUndo)
			{
				[[self undoManager] setActionName:NSLocalizedString(@"Rename", @"Rename undo label")];
				NSString* originalFilename = [file lastPathComponent];
				[[[self undoManager] prepareWithInvocationTarget:self] 
					renameFile:[EGPath pathWithPath:destinationPath]
							to:[EGPath pathWithPath:originalFilename]];
			}
		}
		else
			AlertSoundPlay();
	}
	
	// Release the old current file
	[file release];
	
	return worked;
}

@end

@implementation FileOperations (UndoCategory)

-(BOOL)unCopyFile:(NSString*)oldDestination from:(NSString*)oldSource
{
	[oldDestination retain];
	
	// Delete the oldSource
	NSFileManager* fileManager = [NSFileManager defaultManager];
	BOOL worked = NO;
	
	if([fileManager fileExistsAtPath:oldDestination])
	{
		worked = [[NSFileManager defaultManager] removeFileAtPath:oldDestination
														  handler:nil];
		
//		if(worked)
//			[viewAsIconsController removeFile:oldDestination];
//		else
//			AlertSoundPlay();
	}
	else
		AlertSoundPlay();
	
	// If the source exists, we can undo this operation...
	if([fileManager fileExistsAtPath:oldSource])
	{
		[[self undoManager] setActionName:NSLocalizedString(@"Copy", 
															@"Copy undo label")];
		[[[self undoManager] prepareWithInvocationTarget:self]
				copyFile:[EGPath pathWithPath:oldSource]
					  to:[EGPath pathWithPath:
						  [oldDestination stringByDeletingLastPathComponent]]];		
	}
	
	[oldDestination release];
	
	return worked;
}

-(BOOL)removeOverwriteFile:(NSString*)fileToOverwrite
{
	NSString* destDir = [[NSValueTransformer valueTransformerForName:
		@"FullDisplayNameValueTransformer"] transformedValue:
		[fileToOverwrite stringByDeletingLastPathComponent]];
	
	// Okay, so the file already exists. Let's ask the user for guidance
	NSString* format = NSLocalizedString(@"An item named '%@' already exists in the folder '%@'. This operation cannot be undone.", 
										 @"Warning message when user would overwrite a file");
	NSString* messageText = NSLocalizedString(@"Overwrite file?", 
											  @"Warning message when user would overwrite a file");
	NSString* overwriteButton = NSLocalizedString(@"Overwrite", 
												  @"Overwrite button in warning message");
	NSString* cancelButton = NSLocalizedString(@"Cancel",
											   @"Overwrite button in warning message");
	
	NSString* text = [NSString stringWithFormat:format, [fileToOverwrite lastPathComponent], 
		destDir];
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

-(NSUndoManager*)undoManager
{
	return [[[[NSApp mainWindow] windowController] document] undoManager];
}

@end