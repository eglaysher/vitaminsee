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
	
	// Now we build thumbnails for each image.
	NSString* path;
	int row = 0;
	NSEnumerator* e = [fileList objectEnumerator];
	while(path = [e nextObject])
	{
//		NSLog(@"Working with path %@", path);
		[imageTaskManager buildThumbnailFor:path row:row];
		row++;
	}
}

-(NSView*)view
{
	return ourBrowser;
}

// Implement the NSBrowser delegate protocal
//- (int)browser:(NSBrowser *)sender numberOfRowsInColumn:(int)column {
//	return [fileList count];
//}

-(void)browser:(NSBrowser*)sender
createRowsForColumn:(int)column
	  inMatrix:(NSMatrix*)matrix
{
	int i;
	int count = [fileList count];
	
	[matrix setCellClass:[ViewAsIconViewCell class]];
	[matrix renewRows:count columns:1];
}

- (void)browser:(NSBrowser *)sender 
willDisplayCell:(id)cell 
		  atRow:(int)row
		 column:(int)column 
{
	// Set the properties of this cell.
//	NSLog(@"Setting properties for row %d", row);
	[(ViewAsIconViewCell*)cell setCellPropertiesFromPath:[fileList objectAtIndex:row]
									withImageTaskManager:imageTaskManager
													 row:row];
}

-(void)singleClick:(NSBrowser*)sender
{
	// Check to see if the user clicked on the cell already selected.
//	id selectedCell = [sender selectedCell];
//	if(selectedCell == currentlySelectedCell)
//	{
//		[self editCurrentCell:sender];
//		return;
//	}
	
	// grab the image path
	NSString* absolutePath = [[sender path] fileWithPath:currentDirectory];
	NSMutableArray* preloadList = [NSMutableArray array];
	
	[controller setCurrentFile:absolutePath];
	
//	currentlySelectedCell = selectedCell;
	
	// If this is a directory, preload the first file of
	if([absolutePath isDir])
	{
		NSEnumerator* dirEnum = [[[NSFileManager defaultManager] 
			directoryContentsAtPath:currentDirectory] objectEnumerator];
		NSMutableArray* myFileList = [[NSMutableArray array] retain];
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
	NSString* absolutePath = [[sender path] fileWithPath:currentDirectory];
	
	if([absolutePath isDir])
	{
		// Get the first image in the directory:		
		[controller setCurrentDirectory:absolutePath];
	}
	
	// [controller setCurrentDirectory:] will call [self setCurrentDirectory:] which
	// will manage all our stuff...
}

//-(void)editCurrentCell:(NSBrowser*)sender
//{
//	NSCell *selectedCell = [sender selectedCell];
//	NSRect cellFrame;
//	NSMatrix *theMatrix;
//	int selectedRow, selectedColumn;
//	
//	//these might be slightly different depending on what cell you
//	// want to edit
//	selectedColumn = [sender selectedColumn];
//	selectedRow = [sender selectedRowInColumn:selectedColumn];
//	
//	theMatrix = [sender matrixInColumn:selectedColumn];
//	
//	//note that the matrix itself only has one column, so we pass in 0
//	cellFrame = [theMatrix cellFrameAtRow:selectedRow column:0];
//	[selectedCell setEditable:YES];
//	[selectedCell editWithFrame:cellFrame
//						 inView:theMatrix
//						 editor:[[sender window] fieldEditor:YES 
//												   forObject:selectedCell]
//		
//					   delegate:self
//						  event:nil]; 
//	[selectedCell setEditable:NO];
////	[selectedCell update
//		[theMatrix updateCell:selectedCell];
////	[theMatrix set`
//}

// GRRRRR: This is STILL O(n). I lied in the last commit comments!
-(void)removeFileFromList:(NSString*)absolutePath
{
	int filesInDir = [fileList count];
	int i;
	for(i = 0; i < filesInDir; ++i)
		if([[fileList objectAtIndex:i] isEqual:absolutePath])
		{
			[fileList removeObjectAtIndex:i];
			[ourBrowser reloadColumn:0];
			break;
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

-(void)setThumbnail:(NSImage*)thumbnail
			forFile:(NSString*)file
				row:(int)row
{
	NSMatrix* matrix = [ourBrowser matrixInColumn:0];
//	NSLog(@"Image: %@Row: %d", thumbnail, row);
	ViewAsIconViewCell* cell = [matrix cellAtRow:row column:0];
//	NSLog(@"Cell: %@", cell);
//	if([[cell cellPath] isEqual:file])
//	{
		[cell setIconImage:thumbnail];
		[matrix putCell:cell atRow:row column:0];
		[ourBrowser updateCell:cell];
//	}
//	else
//	{
//		NSLog(@"Mismatch: Cellpath: '%@' File: '%@' on row %d of %d rows", 
//			  [cell cellPath], file, row, [matrix numberOfRows] - 1);
////		NSLog(@"WARNING! cell/row mismatch!");
//	}
}

@end

@implementation ViewIconViewController (Private)
-(void)rebuildInternalFileArray
{
	NSEnumerator* dirEnum = [[[NSFileManager defaultManager] 
		directoryContentsAtPath:currentDirectory] objectEnumerator];
	NSMutableArray* myFileList = [[NSMutableArray array] retain];
	NSString* curFile;
	while(curFile = [dirEnum nextObject])
	{
		NSString* currentFileWithPath = [curFile fileWithPath:currentDirectory];
		if([currentFileWithPath isDir] || [currentFileWithPath isImage])
			[myFileList addObject:currentFileWithPath];
	}
	
	// Now sort the list since some filesystems (*cough*SAMBA*cough*) don't
	// present files sorted alphabetically...
//	[fileList sortUsingSelector:@selector(compare:)];	

	[fileList release];
	[myFileList retain];
	fileList = myFileList;
}
@end
