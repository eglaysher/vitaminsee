//
//  ViewIconViewController.m
//  CQView
//
//  Created by Elliot on 2/9/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "AppKitAdditions.h"
#import "ViewIconViewController.h"
#import "ViewAsIconViewCell.h"
#import "VitaminSEEController.h"
#import "NSString+FileTasks.h"
#import "ThumbnailManager.h"
#import "IconFamily.h"

@interface ViewIconViewController (Private)
-(void)rebuildInternalFileArray;
@end

@implementation ViewIconViewController

//-(id)init
//{
//	if(self = [super init])
//	{
-(void)awakeFromNib
{
	[ourBrowser setTarget:self];
		[ourBrowser setAction:@selector(singleClick:)];
		[ourBrowser setDoubleAction:@selector(doubleClick:)];	
		[ourBrowser setCellClass:[ViewAsIconViewCell class]];
		[ourBrowser setDelegate:self];
		
		currentlySelectedCell = nil;
	}
	
//	return self;
//}

-(BOOL)canDelete
{
	return [fileList count] > 0;
}

-(void)setThumbnailManager:(ThumbnailManager*)itm
{
	thumbnailManager = itm;
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
	BOOL buildThumbnails = [[userDeffault objectForKey:@"GenerateThumbnails"] boolValue];

	// Tell the imageTaskManager if it should actually build the thumbnails
	[thumbnailManager setShouldBuildIcon:buildThumbnails];	

	for(i = 0; i < count; ++i)
	{
		id cell = [matrix cellAtRow:i column:0];
		NSString* currentFile = [fileList objectAtIndex:i];
		[cell setCellPropertiesFromPath:currentFile];

		// This doesn't properly detect the existance of a thumbnail...
		if(buildThumbnails && [currentFile isImage] && 
		   ![IconFamily fileHasCustomIcon:currentFile] )
		{
			// Put in a placeholder icon (the default filetype icon) for now.
			// It'll be replaced later. I'd prefer to defer this work, but that
			// would require hard changes. Besides, -iconForFileType is cheap.
			[cell setIconImage:[[NSWorkspace sharedWorkspace] iconForFileType:
				[currentFile pathExtension]]];
			
			[thumbnailManager buildThumbnail:currentFile];
		}
		else
			[cell loadOwnIconOnDisplay];

//		[cell setLoaded:NO];
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
	NSString* absolutePath = [[currentDirectory stringByAppendingPathComponent:
		[sender path]] stringByStandardizingPath];
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
			NSString* currentFileWithPath = [currentDirectory 
				stringByAppendingPathComponent:curFile];
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
	NSString* absolutePath = [[currentDirectory stringByAppendingPathComponent:
		[ourBrowser path]] stringByStandardizingPath];
	
	if([absolutePath isDir])
	{
		// Get the first image in the directory:		
		[controller setCurrentDirectory:absolutePath file:nil];
	}
	
	// [controller setCurrentDirectory:] will call [self setCurrentDirectory:] which
	// will manage all our stuff...
}

// Binary search across our files for a certain node to remove. Much faster then
// the previous linear search...
-(void)removeFile:(NSString*)absolutePath
{
	unsigned index = [fileList binarySearchFor:absolutePath 
		withSortSelector:@selector(caseInsensitiveCompare:)];

	NSMatrix* matrix = [ourBrowser matrixInColumn:0];
	if(index != NSNotFound)
	{
		if(index == [matrix selectedRow])
		{
			NSString* file = [self nameOfNextFile];
			[self selectFile:file];
			[controller setCurrentFile:file];
		}
			
		[fileList removeObjectAtIndex:index];

		[matrix removeRow:index];
		[matrix sizeToCells];
		[ourBrowser setNeedsDisplay];
		
		if([fileList count] == 0)
			// We better say no image.
			[controller setCurrentFile:nil];
	}
}

-(void)addFile:(NSString*)path
{
	if([currentDirectory isEqual:[path stringByDeletingLastPathComponent]])
	{
		unsigned index = [fileList lowerBoundToInsert:path 
						 withSortSelector:@selector(caseInsensitiveCompare:)];
	
		if(index != [fileList count])
			[fileList insertObject:path atIndex:index];
		else
			[fileList addObject:path];
	
		NSMatrix* m = [ourBrowser matrixInColumn:0];
		[m insertRow:index];
		
		// FIXME: This needs to be generalized. What happens if this file doesn't have
		// a thumbnail, a thumbnail request is generated, the file is moved, and then
		// the thumbnail comes in!?
		[[m cellAtRow:index column:0] loadOwnIconOnDisplay];
		[self browser:ourBrowser willDisplayCell:[m cellAtRow:index column:0] 
				atRow:index column:0];
		[m sizeToCells];
	
		// Select this file.
		[m selectCellAtRow:index column:0];
		[controller setCurrentFile:[fileList objectAtIndex:index]];
		
		[ourBrowser setNeedsDisplay];
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
	{
		[ourBrowser setPath:[NSString pathWithComponents:[NSArray arrayWithObjects:
			@"/", [fileToSelect lastPathComponent], nil]]];
	}
}

-(void)updateCell:(id)cell
{
	[[ourBrowser matrixInColumn:0] updateCell:cell];
}

-(void)makeFirstResponderTo:(NSWindow*)window
{
	[window makeFirstResponder:ourBrowser];
}

-(void)setThumbnail:(NSImage*)image 
			forFile:(NSString*)path
{
	unsigned index = [fileList binarySearchFor:path 
							  withSortSelector:@selector(caseInsensitiveCompare:)];
	if(index != NSNotFound)
	{
		id cell = [[ourBrowser matrixInColumn:0] cellAtRow:index column:0];
		[cell setIconImage:image];
		[ourBrowser setNeedsDisplay];
	}
}

@end

@implementation ViewIconViewController (Private)

-(void)rebuildInternalFileArray
{
	NSArray* directoryContents = [[NSFileManager defaultManager] 
		directoryContentsAtPath:currentDirectory];
	NSEnumerator* dirEnum = [directoryContents objectEnumerator];
	NSMutableArray* myFileList = [NSMutableArray arrayWithCapacity:[directoryContents count]];
	NSString* curPath;
	while(curPath = [dirEnum nextObject])
	{
		//Assumption: curFile[0] == '/'.
		NSString* currentFileWithPath = [[currentDirectory 
			stringByAppendingPathComponent:curPath] stringByStandardizingPath];
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
