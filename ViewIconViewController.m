//
//  ViewIconViewController.m
//  CQView
//
//  Created by Elliot on 2/9/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "ViewIconViewController.h"
#import "ViewAsIconViewCell.h"
#import "VitaminSEEController.h"
#import "NSString+FileTasks.h"
#import "ImageTaskManager.h"
#import "IconFamily.h"

@interface ViewIconViewController (Private)
-(void)rebuildInternalFileArray;
@end

@implementation ViewIconViewController

-(void)awakeFromNib
{
	[ourBrowser setTarget:self];
	[ourBrowser setAction:@selector(singleClick:)];
	[ourBrowser setDoubleAction:@selector(doubleClick:)];	
	[ourBrowser setCellClass:[ViewAsIconViewCell class]];
	[ourBrowser setDelegate:self];
	
	currentlySelectedCell = nil;
}

-(BOOL)canDelete
{
	return [fileList count] > 0;
}

-(void)setImageTaskManager:(ImageTaskManager*)itm
{
	imageTaskManager = itm;
}

-(void)setCurrentDirectory:(NSString*)path
{
	// If this method has been called, something outside of the ViewAsIcons 
	// NSbrowser set the path, so we'll have to regenerate everything.
	[currentDirectory release];
	[path retain];
	currentDirectory = path;
	
	[self rebuildInternalFileArray];
	
	// Now reload the data
	[ourBrowser setCellClass:[ViewAsIconViewCell class]];
	[ourBrowser loadColumnZero];
	
	// Select the first file
	[ourBrowser selectRow:0 inColumn:0];
	[self singleClick:ourBrowser];	
}

-(NSView*)view
{
	return ourBrowser;
}

// Delegate method for our browser. We are an active delegate so we can message
// the ITM to build an icon for us
-(void)browser:(NSBrowser*)sender
createRowsForColumn:(int)column
	  inMatrix:(NSMatrix*)matrix
{
	int i;
	int count = [fileList count];
	[matrix setMode:NSListModeMatrix];
	[matrix renewRows:count columns:1];
	
	id userDeffault = [NSUserDefaults standardUserDefaults];
	BOOL displayThumbnails = [[userDeffault objectForKey:@"DisplayThumbnails"] boolValue];
	BOOL buildThumbnails = [[userDeffault objectForKey:@"GenerateThumbnails"] boolValue];

	// Tell the imageTaskManager if it should actually build the thumbnails
	[imageTaskManager setShouldBuildIcon:buildThumbnails];
	
	for(i = 0; i < count; ++i)
	{
		id cell = [matrix cellAtRow:i column:0];
		NSString* currentFile = [fileList objectAtIndex:i];
		[cell setCellPropertiesFromPath:currentFile];
		if(displayThumbnails && [currentFile isImage] && 
		   ![IconFamily fileHasCustomIcon:currentFile])
		{
			// Put in a placeholder icon (the default filetype icon) for now.
			// It'll be replaced later. I'd prefer to defer this work, but that
			// would require hard changes. Besides, -iconForFileType is cheap.
			[cell setIconImage:[[NSWorkspace sharedWorkspace] iconForFileType:
				[currentFile pathExtension]]];
			
			[imageTaskManager buildThumbnail:currentFile forCell:cell];
		}
		else
		{
			[cell loadOwnIconOnDisplay];
		}
	}
}

- (void)browser:(NSBrowser *)sender 
willDisplayCell:(id)cell 
		  atRow:(int)row
		 column:(int)column
{
//	NSLog(@"Going to display cell: %@", [cell cellPath]);
	NSString* currentFile = [fileList objectAtIndex:row];
	[cell setCellPropertiesFromPath:currentFile];
	[[sender matrixInColumn:0] updateCell:cell];
}

- (void)clearCache
{
	// Reset the cells so they regenerate their cached titles...
	id matrix = [ourBrowser matrixInColumn:0];
	int numberOfRows = [matrix numberOfRows];
	int i;
	for(i = 0; i < numberOfRows; ++i)
		[[matrix cellAtRow:i column:0] resetTitleCache];
}

-(void)singleClick:(NSBrowser*)sender
{
	// grab the image path
	NSString* absolutePath = [[sender path] fileWithPath:currentDirectory];
	NSMutableArray* preloadList = [NSMutableArray array];	
	
	[controller setCurrentFile:absolutePath];
	
	// Hi! My name is UGLY HACK. I'm here because Apple's NSScrollView has a
	// subtle bug about the areas needed to visually redrawn, so we have to 
	// redisplay THE WHOLE ENCHILADA when we scroll since there's a 1/5~ish
	// chance that the location where the top image cell would be will be the 
	// target drawing location of two or three cells.
	[ourBrowser setNeedsDisplay];
	
	// If this is a directory, preload the first file of
	if([absolutePath isDir])
	{
		NSEnumerator* dirEnum = [[[NSFileManager defaultManager] 
			directoryContentsAtPath:currentDirectory] objectEnumerator];
		NSString* curFile;
	
		while(curFile = [dirEnum nextObject])
		{
			NSString* currentFileWithPath = [curFile fileWithPath:currentDirectory];
			if([currentFileWithPath isImage])
			{
				[preloadList addObject:currentFileWithPath];
				break;
			}
		}
	}
	
	// Get the previous and next file...
	int selectedColumn = [sender selectedColumn];
	int selectedRow = [sender selectedRowInColumn:selectedColumn];
	int toLoad;
	
	// Previous file
	toLoad = selectedRow - 1;
	id node = [[sender loadedCellAtRow:toLoad column:selectedColumn] cellPath];
	if(node && [node isImage])
		[preloadList addObject:node];
	
	// Next file
	toLoad = selectedRow + 1;
	node = [[sender loadedCellAtRow:toLoad column:selectedColumn] cellPath];
	if(node && [node isImage])
		[preloadList addObject:node];
	
	// Preload these files
	[controller preloadFiles:preloadList];
}

-(void)doubleClick:(NSBrowser*)sender
{
	// Double clicking sets the directory...if it's a directory
	NSString* absolutePath = [[ourBrowser path] fileWithPath:currentDirectory];
	
	if([absolutePath isDir])
	{
		// Get the first image in the directory:		
		[controller setCurrentDirectory:absolutePath file:nil];
	}
	
	// [controller setCurrentDirectory:] will call [self setCurrentDirectory:] which
	// will manage all our stuff...
}


// I should really make a SortedArray datastructure, since I repeat the binary
// search way to many times...
-(void)renameFile:(NSString*)absolutePath to:(NSString*)newPath
{
	int low = -1;
	int high = [fileList count];
	int current;
	
	while(high - low > 1)
	{
		current = (high + low) / 2;
		if([absolutePath caseInsensitiveCompare:[fileList objectAtIndex:current]] == 
		   NSOrderedDescending)
		{
			low = current;
		}
		else
		{
			high = current;
		}
	}
	
	if(high == [fileList count] || [[fileList objectAtIndex:high] 
		caseInsensitiveCompare:absolutePath] != NSOrderedSame)
		NSLog(@"HUH!? %@ isn't in the current directory!?", absolutePath);
	else
	{
		[fileList replaceObjectAtIndex:high withObject:newPath];
		[fileList sortUsingSelector:@selector(caseInsensitiveCompare:)];
				
		[ourBrowser loadColumnZero];
		[ourBrowser setPath:[newPath lastPathComponent]];
	}	
}

// Binary search across our files for a certain node to remove. Much faster then
// the previous linear search...
-(void)removeFileFromList:(NSString*)absolutePath
{
	int low = -1;
	int high = [fileList count];
	int current;
	
	while(high - low > 1)
	{
		current = (high + low) / 2;
		if([absolutePath caseInsensitiveCompare:[fileList objectAtIndex:current]] == 
		   NSOrderedDescending)
		{
			low = current;
		}
		else
		{
			high = current;
		}
	}
	
	if(high == [fileList count] || [[fileList objectAtIndex:high] 
		caseInsensitiveCompare:absolutePath] != NSOrderedSame)
		NSLog(@"HUH!? %@ isn't in the current directory!?", absolutePath);
	else
	{
		[fileList removeObjectAtIndex:high];

		// Known problem: Deleting a file doesn't affect the scroll bar.
		// Solution: Don't use an NSBrowser. (I'll be rewriting this as a 
		//           loadable bundle with an NSTableView...)
		[[ourBrowser matrixInColumn:0] removeRow:high];
		[ourBrowser setNeedsDisplay];
		
		if([fileList count] == 0)
			// We better say no image.
			[controller setCurrentFile:nil];
	}
}

// Returns the path of the next cell that would be selected if the current cell
// were to be removed.
-(NSString*)nameOfNextFile
{
	NSMatrix* matrix = [ourBrowser matrixInColumn:0];
	int selected = [matrix selectedRow];
	NSString* nextFile = nil;
	
	// Get either the next or the previous cell
	id cell = [matrix cellAtRow:(selected + 1) column:0];
	if(!cell)
		cell = [matrix cellAtRow:(selected - 1) column:0];
	
	// If we got a cell
	if(cell)
		nextFile = [cell cellPath];
	
	return nextFile;
}

-(void)selectFile:(NSString*)fileToSelect
{
	if(fileToSelect)
		[ourBrowser setPath:[NSString pathWithComponents:[NSArray arrayWithObjects:
			@"/", [fileToSelect lastPathComponent], nil]]];
}

-(void)updateCell:(id)cell
{
	[[ourBrowser matrixInColumn:0] updateCell:cell];
//	[ourBrowser updateCell:cell];
	//	[ourBrowser setNeedsDisplay];
}

-(void)makeFirstResponderTo:(NSWindow*)window
{
	[window makeFirstResponder:ourBrowser];
}

@end

@implementation ViewIconViewController (Private)

-(void)rebuildInternalFileArray
{
	NSArray* directoryContents = [[NSFileManager defaultManager] 
		directoryContentsAtPath:currentDirectory];
	NSEnumerator* dirEnum = [directoryContents objectEnumerator];
	NSMutableArray* myFileList = [NSMutableArray arrayWithCapacity:[directoryContents count]];
	NSString* curFile;
	while(curFile = [dirEnum nextObject])
	{
		NSString* currentFileWithPath = [curFile fileWithPath:currentDirectory];
		if(([currentFileWithPath isDir] || [currentFileWithPath isImage]) &&
		   [currentFileWithPath isVisible])
			[myFileList addObject:currentFileWithPath];
	}
	
	// Now sort the list since some filesystems (*cough*SAMBA*cough*) don't
	// present files sorted alphabetically and we do binary searches to avoid
	// O(n) overhead later on.
	[myFileList sortUsingSelector:@selector(caseInsensitiveCompare:)];	

	[fileList release];
	[myFileList retain];
	fileList = myFileList;
}

@end
