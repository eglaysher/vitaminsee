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

@interface ViewIconViewController (Private)
-(void)rebuildInternalFileArray;
@end

@implementation ViewIconViewController

-(void)awakeFromNib
{
	[ourBrowser setTarget:self];
	[ourBrowser setAction: @selector(singleClick:)];
	[ourBrowser setDoubleAction: @selector(doubleClick:)];	
}

-(void)setCurrentDirectory:(NSString*)path
{
	// If this method has been called, something outside of the ViewAsIcons 
	// NSbrowser set the path, so we'll have to regenerate everything.
	[currentDirectory release];
	[path retain];
	currentDirectory = path;
	
	//	NSString* currentDirectory = 
	NSLog(@"VieAsIconsDelegate: Setting internal path to %@", path);

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

// Implement the NSBrowser delegate protocal
- (int)browser:(NSBrowser *)sender numberOfRowsInColumn:(int)column {
	return [fileList count];
}

- (void)browser:(NSBrowser *)sender 
willDisplayCell:(id)cell 
		  atRow:(int)row
		 column:(int)column 
{
// Okay, now I have to screw with the cells...
	[(ViewAsIconViewCell*)cell setCellPropertiesFromPath:[fileList objectAtIndex:row]];
//setTitle:[[fileList objectAtIndex:row] lastPathComponent]];
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
		else
			NSLog(@"Rejecting %@", curFile);
	}
	
	// Now sort the list since some filesystems (*cough*SAMBA*cough*) don't
	// present files sorted alphabetically...
//	[fileList sortUsingSelector:@selector(compare:)];
	
	NSLog(@"Here's the list of files in this directory: %@", myFileList);

	[fileList release];
	[myFileList retain];
	fileList = myFileList;
}
@end
