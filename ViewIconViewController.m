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

///////////////
//@interface NSMatrixWithClickEditing : NSMatrix {
//}
//@end
//
//@implementation NSMatrixWithClickEditing
//- (void)selectCellAtRow:(int)row column:(int)column
//{
//	NSLog(@"Select Cell at row:%d column:%d", row, column);
//	// First, we need to know which item we are dealing with
//	NSCell* cellToSelect = [super cellAtRow:row column:column];
//	
//	// We tell all selected cells that they aren't edited anymore
//	NSEnumerator* e = [[self selectedCells] objectEnumerator];
//	NSCell* cell;
//	while(cell = [e nextObject])
//		if([cell isEqualTo:cellToSelect])
//			[cell setEditable:NO];
//		
//	[super selectCellAtRow:row column:column];
//	[[super cellAtRow:row column:column] setEditable:YES];
//}
//@end

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

-(void)setCurrentDirectory:(NSString*)path
{
	// If this method has been called, something outside of the ViewAsIcons 
	// NSbrowser set the path, so we'll have to regenerate everything.
	[currentDirectory release];
	[path retain];
	currentDirectory = path;
	
	//	NSString* currentDirectory = 
//	NSLog(@"VieAsIconsDelegate: Setting internal path to %@", path);

	[self rebuildInternalFileArray];
	
	// Now reload the data
	[ourBrowser setCellClass:[ViewAsIconViewCell class]];
//	[ourBrowser setMatrixClass:[NSMatrixWithClickEditing class]];
	[ourBrowser loadColumnZero];
	
	// Select the first file
	[ourBrowser selectRow:0 inColumn:0];
	[self singleClick:ourBrowser];
}

-(NSView*)view
{
	return ourBrowser;
}

// Implement the NSBrowser delegate protocal
- (int)browser:(NSBrowser *)sender numberOfRowsInColumn:(int)column {
	return [fileList count];
}

- (void)browser:(NSBrowser *)sender 
willDisplayCell:(id)cell 
		  atRow:(int)row
		 column:(int)column 
{
	// Set the properties of this cell.
	[(ViewAsIconViewCell*)cell setCellPropertiesFromPath:[fileList objectAtIndex:row]];
}

//browser:selectRow:inColumn:
//- (BOOL)browser:(NSBrowser *)sender selectRow:(int)row inColumn:(int)column
//{
//	// Okay, first we actually SELECT the row/column. We can't call
//	// -[NSBrowser selectRow:inColumn:] because that function is calling US...
//	[[sender matrixInColumn:column] selectCellAtRow:row column:0];
//		
//	NSLog(@"Setting to editable...");
//	// Now we set the row/column cell to editable.
//	[[sender loadedCellAtRow:row column:column] setEditable:YES];
//	
//	return YES;
//}

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

-(void)editCurrentCell:(NSBrowser*)sender
{
	NSCell *selectedCell = [sender selectedCell];
	NSRect cellFrame;
	NSMatrix *theMatrix;
	int selectedRow, selectedColumn;
	
	//these might be slightly different depending on what cell you
	// want to edit
	selectedColumn = [sender selectedColumn];
	selectedRow = [sender selectedRowInColumn:selectedColumn];
	
	theMatrix = [sender matrixInColumn:selectedColumn];
	
	//note that the matrix itself only has one column, so we pass in 0
	cellFrame = [theMatrix cellFrameAtRow:selectedRow column:0];
	[selectedCell setEditable:YES];
	[selectedCell editWithFrame:cellFrame
						 inView:theMatrix
						 editor:[[sender window] fieldEditor:YES 
												   forObject:selectedCell]
		
					   delegate:self
						  event:nil]; 
	[selectedCell setEditable:NO];
//	[selectedCell update
		[theMatrix updateCell:selectedCell];
//	[theMatrix set`
}

-(void)removeFileFromList:(NSString*)absolutePath
{
//	NSMatrix* matrix = [ourBrowser matrixInColumn:0];
//	int matrixRows = [matrix numberOfRows];
//	int i;
//	for(i = 0; i < matrixRows; ++i)
//	{
//		if([[[matrix cellAtRow:i column:0] cellPath] isEqual:absolutePath])
//		{
//			NSLog(@"Removing row number %d", i);
//			break;
//		}
//	}

	int filesInDir = [fileList count];
	int i;
	for(i = 0; i < filesInDir; ++i)
		if([[fileList objectAtIndex:i] isEqual:absolutePath])
		{
			NSLog(@"Removing row number %d", i);
			[fileList removeObjectAtIndex:i];
			[ourBrowser reloadColumn:0];
			break;
		}
}

-(void)selectFile:(NSString*)fileToSelect
{
//	NSLog(@"Setting filetoselect to %@", fileToSelect);
	[ourBrowser setPath:[NSString pathWithComponents:[NSArray arrayWithObjects:
		@"/", [fileToSelect lastPathComponent], nil]]];
//	[[ourBrowser window] makeFirstResponder:ourBrowser];
	
	// Why the HELL doesn't that work!?
//	[ourBrowser setNeedsDisplay];
//	[[ourBrowser window] makeFirstResponder:ourBrowser];
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
//		else
//			NSLog(@"Rejecting %@", curFile);
	}
	
	// Now sort the list since some filesystems (*cough*SAMBA*cough*) don't
	// present files sorted alphabetically...
//	[fileList sortUsingSelector:@selector(compare:)];
	
//	NSLog(@"Here's the list of files in this directory: %@", myFileList);

	[fileList release];
	[myFileList retain];
	fileList = myFileList;
}
@end
