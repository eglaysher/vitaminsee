//
//  ViewIconViewController.m
//  CQView
//
//  Created by Elliot on 2/9/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "ViewIconViewController.h"
#import "ViewAsIconViewCell.h"
#import "CQViewController.h"
#import "NSString+FileTasks.h"
#import "ImageTaskManager.h"

@interface ViewIconViewController (Private)
-(void)rebuildInternalFileArray;
@end

@implementation ViewIconViewController

-(void)awakeFromNib
{
	[ourBrowser setTarget:self];
	[ourBrowser setAction: @selector(singleClick:)];
	[ourBrowser setDoubleAction: @selector(doubleClick:)];	
	[ourBrowser setCellClass:[ViewAsIconViewCell class]];
	
	currentlySelectedCell = nil;
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
//		NSLog(@"Loading...");
		id cell = [matrix cellAtRow:i column:0];
		NSString* currentFile = [fileList objectAtIndex:i];
		[cell setCellPropertiesFromPath:currentFile];
		if(displayThumbnails || [currentFile isDir])
			[imageTaskManager buildThumbnail:currentFile forCell:cell];
	}
}

-(void)singleClick:(NSBrowser*)sender
{
	// grab the image path
	NSString* absolutePath = [[sender path] fileWithPath:currentDirectory];
	NSMutableArray* preloadList = [NSMutableArray array];	
	
	[controller setCurrentFile:absolutePath];
	
	// If this is a directory, preload the first file of
	if([absolutePath isDir])
	{
		NSEnumerator* dirEnum = [[[NSFileManager defaultManager] 
			directoryContentsAtPath:currentDirectory] objectEnumerator];
//		NSMutableArray* myFileList = [[NSMutableArray array] retain];
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
		
		NSLog(@"FileList: %@", fileList);
		
		[ourBrowser loadColumnZero];
		[ourBrowser setPath:[newPath lastPathComponent]];
//		[[ourBrowser matrixInColumn:0] addRo
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
		[[ourBrowser matrixInColumn:0] removeRow:high];
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
	[ourBrowser updateCell:cell];
}

@end

@implementation ViewIconViewController (Private)
-(void)rebuildInternalFileArray
{
	NSEnumerator* dirEnum = [[[NSFileManager defaultManager] 
		directoryContentsAtPath:currentDirectory] objectEnumerator];
	NSMutableArray* myFileList = [NSMutableArray array];
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
	// O(n) overhead.
	[fileList sortUsingSelector:@selector(caseInsensitiveCompare:)];	

	[fileList release];
	[myFileList retain];
	fileList = myFileList;
}
@end
