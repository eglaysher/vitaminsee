/////////////////////////////////////////////////////////////////////////
// File:          $Name$
// Module:        Implements the View as icons file browser
// Part of:       VitaminSEE
//
// Revision:      $Revision$
// Last edited:   $Date$
// Author:        $Author$
// Copyright:     (c) 2005 Elliot Glaysher
// Created:       2/9/05
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

#import "AppKitAdditions.h"
#import "ViewIconViewController.h"
#import "ViewAsIconViewCell.h"
#import "VitaminSEEController.h"
#import "NSString+FileTasks.h"
#import "ThumbnailManager.h"
#import "IconFamily.h"
#import "PluginLayer.h"

@interface ViewIconViewController (Private)
-(void)rebuildInternalFileArray;
@end

@implementation ViewIconViewController

-(id)initWithPluginLayer:(PluginLayer*)inPluginLayer
{
	if(self = [super init])
	{
		[NSBundle loadNibNamed:@"ViewAsIconsView" owner:self];

		pluginLayer = inPluginLayer;
		[pluginLayer retain];
		oldPosition = -1;
	}

	return self;
}

-(void)dealloc
{
	[pluginLayer release];
}
	
-(void)awakeFromNib
{
	[ourBrowser setTarget:self];
	[ourBrowser setAction:@selector(singleClick:)];
	[ourBrowser setDoubleAction:@selector(doubleClick:)];	
	[ourBrowser setCellClass:[ViewAsIconViewCell class]];
	[ourBrowser setDelegate:self];
	
	currentlySelectedCell = nil;
}

//////////////////////////////////////////////////////////// PROTOCOL: FileView
-(BOOL)fileIsInView:(NSString*)fileIsInView
{
	BOOL isCurDir = [currentDirectory isEqual:[fileIsInView stringByDeletingLastPathComponent]];
	
	if(isCurDir)
	{
		NSArray* cells = [ourBrowser selectedCells];
		NSEnumerator* e = [cells objectEnumerator];
		id cell;
		while(cell = [e nextObject])
			if([[cell cellPath] isEqual:fileIsInView])
				return true;
	}
	
	return false;
}

-(NSArray*)selectedFiles
{
	NSArray* selectedCells = [ourBrowser selectedCells];
	NSMutableArray* selectedFiles = [NSMutableArray arrayWithCapacity:[selectedCells count]];

	// Add the path of each cell to the array we're returning.
	NSEnumerator* e = [selectedCells objectEnumerator];
	id cell;
	while(cell = [e nextObject])
		[selectedFiles addObject:[cell cellPath]];
	
	return selectedFiles;
}

-(BOOL)canSetCurrentDirectory
{
	return YES;
}

-(BOOL)canGoEnclosingFolder
{
	return [currentDirectoryComponents count];
}

//-(BOOL)canDelete
//{
//	return [fileList count] > 0;
//}

- (void)setCurrentDirectory:(NSString*)newCurrentDirectory
				currentFile:(NSString*)newCurrentFile
{	
	[pluginLayer startProgressIndicator];
	
	if(currentDirectory && newCurrentDirectory && 
	   ![currentDirectory isEqual:newCurrentDirectory])
		[[[pluginLayer pathManager] prepareWithInvocationTarget:self]
			setCurrentDirectory:currentDirectory currentFile:[pluginLayer currentFile]];

	// Clear the thumbnails. They need to be regenerated...
	[pluginLayer clearThumbnailQueue];
	
	// Set the current Directory
	[currentDirectory release];
	currentDirectory = [newCurrentDirectory stringByStandardizingPath];
	[currentDirectory retain];
	
	// Set the current paths components of the directory
	[currentDirectoryComponents release];
	currentDirectoryComponents = [newCurrentDirectory pathComponents];
	[currentDirectoryComponents retain];
	
	// Make an NSMenu with all the path components
	NSEnumerator* e = [currentDirectoryComponents reverseObjectEnumerator];
	NSString* currentComponent;
	NSMenu* newMenu = [[[NSMenu alloc] init] autorelease];
	NSMenuItem* newMenuItem;
	int currentTag = [currentDirectoryComponents count];
	NSSize iconImageSize = NSMakeSize(16, 16);
	while(currentComponent = [e nextObject]) {
		newMenuItem = [[[NSMenuItem alloc] initWithTitle:currentComponent
												  action:@selector(directoryMenuSelected:)
										   keyEquivalent:@""] autorelease];
		[newMenuItem setImage:[[NSString pathWithComponents:
			[currentDirectoryComponents subarrayWithRange:NSMakeRange(0, currentTag)]] 
			iconImageOfSize:iconImageSize]];
		[newMenuItem setTag:currentTag];
		[newMenuItem setTarget:self];
		currentTag--;
		[newMenu addItem:newMenuItem];
	}
	
	// Set this menu as the pull down...
	[directoryDropdown setMenu:newMenu];
	[directoryDropdown setEnabled:YES];

	[self rebuildInternalFileArray];
	
	oldPosition = -1;

	// Now reload the data
	[ourBrowser setCellClass:[ViewAsIconViewCell class]];
	[ourBrowser loadColumnZero];
	
	[pluginLayer stopProgressIndicator];
	
	if(newCurrentFile)
	{
		// Select the previous directory
		[pluginLayer setCurrentFile:newCurrentFile];
		[ourBrowser setPath:[NSString stringWithFormat:@"/%@", 
			[newCurrentFile lastPathComponent]]];
	}
	else
	{
		// Select the first file on the list
		[ourBrowser selectRow:0 inColumn:0];
		[self singleClick:ourBrowser];
	}
}

-(void)directoryMenuSelected:(id)sender
{
	NSString* newDirectory = [NSString pathWithComponents:
		[currentDirectoryComponents subarrayWithRange:NSMakeRange(0,[sender tag])]];
	NSString* directoryToSelect = nil;
	if([sender tag] < [currentDirectoryComponents count])
		directoryToSelect = [NSString pathWithComponents:
			[currentDirectoryComponents subarrayWithRange:NSMakeRange(0,[sender tag]+1)]];
	[self setCurrentDirectory:newDirectory currentFile:directoryToSelect];
}

-(NSView*)view
{
	return ourView;
}

- (int)browser:(NSBrowser *)sender numberOfRowsInColumn:(int)column
{
	return [fileList count];
}

- (void)browser:(NSBrowser *)sender 
willDisplayCell:(id)cell 
		  atRow:(int)row
		 column:(int)column
{
	[cell setCellPropertiesFromPath:[fileList objectAtIndex:row]];
}

- (void)clearCache
{
	// Reset the cells so they regenerate their cached titles...
	id matrix = [ourBrowser matrixInColumn:0];
	int numberOfRows = [matrix numberOfRows];
	int i;
	for(i = 0; i < numberOfRows; ++i)
	{
		id cell = [matrix cellAtRow:i column:0];
		if([cell respondsToSelector:@selector(setIconImage:)])
		{
			[cell resetTitleCache];
		}
	}
}

-(void)singleClick:(NSBrowser*)sender
{
	// grab the image path
	NSString* absolutePath = [currentDirectory stringByAppendingPathComponent:
		[sender path]];
	
	[pluginLayer setCurrentFile:absolutePath];
	
	// Hi! My name is UGLY HACK. I'm here because Apple's NSScrollView has a
	// subtle bug about the areas needed to visually redrawn, so we have to 
	// redisplay THE WHOLE ENCHILADA when we scroll since there's a 1/5~ish
	// chance that the location where the top image cell would be will be the 
	// target drawing location of two or three cells.
	[ourBrowser setNeedsDisplay];
	
	// Now we figure out which file we preload next.
	int preloadRow = -1;
	int newPosition = [sender selectedRowInColumn:0];

	if(newPosition > oldPosition)
	{
		// We are moving down (positive) so preload the next file
		preloadRow = newPosition + 1;
	}
	else if(newPosition < oldPosition)
	{
		// We are moving up (negative) so preload the previous file
		preloadRow = newPosition - 1;
	}
	
	if(preloadRow > -1)
	{
		id node = [[ourBrowser loadedCellAtRow:preloadRow column:0] cellPath];
		if(node && [node isImage])
			[pluginLayer preloadFile:node];
	}

	oldPosition = newPosition;
}

-(void)doubleClick:(NSBrowser*)sender
{
	// Double clicking sets the directory...if it's a directory
	NSString* absolutePath = [currentDirectory stringByAppendingPathComponent:
		[ourBrowser path]];
	
	if([absolutePath isDir])
	{
		// Get the first image in the directory:		
		[self setCurrentDirectory:absolutePath currentFile:nil];
	}
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
			[pluginLayer setCurrentFile:file];
		}

		[fileList removeObjectAtIndex:index];
		
		// This really shouldn't be here, but -[NSBrowser reloadColumn:] has issues, and 
		// this is the only workaround I can think of.
		[[ourBrowser matrixInColumn:0] removeRow:index];
		
		// Tell our browser to redisplay. We can't rely on removing the row from the matrix
		// (even if we update almost
		[ourBrowser reloadColumn:0];
		[ourBrowser setNeedsDisplay];
		
		if([fileList count] == 0)
			// We better say no image.
			[pluginLayer setCurrentFile:nil];
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

		// Add it to the list of files to thumbnail. Either it already has a 
		// thumbnail
		[pluginLayer generateThumbnailForFile:path];
		
		// Redisplay and select the added file
		[ourBrowser loadColumnZero];
		[ourBrowser setPath:[NSString stringWithFormat:@"/%@", [path lastPathComponent]]];
		
		[pluginLayer setCurrentFile:[fileList objectAtIndex:index]];
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
		// Set this image if we've already tried to view it.
		id cell = [[ourBrowser matrixInColumn:0] cellAtRow:index column:0];
		if([cell respondsToSelector:@selector(setIconImage:)])
		{
			[cell setIconImage:image];
			[ourBrowser setNeedsDisplay];
		}
	}
	else
		NSLog(@"Warning! %@ wasn't found when setting it's thumbnail!", path);
}

-(void)goEnclosingFolder
{
	int count = [currentDirectoryComponents count] - 1;
	NSString* curDirCopy = [currentDirectory retain];
	[self setCurrentDirectory:[NSString pathWithComponents:
		[currentDirectoryComponents subarrayWithRange:NSMakeRange(0, count)]]
						 currentFile:curDirCopy];
	[curDirCopy release];	
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
		NSString* currentFileWithPath = [currentDirectory 
			stringByAppendingPathComponent:curPath];
				
		if(([currentFileWithPath isDir] || [currentFileWithPath isImage]) &&
		   [currentFileWithPath isVisible])
		{			
			[myFileList addObject:currentFileWithPath];
		}
	}
	
	// Now sort the list since some filesystems (*cough*SAMBA*cough*) don't
	// present files sorted alphabetically and we do binary searches to avoid
	// O(n) overhead later on.
	[myFileList sortUsingSelector:@selector(caseInsensitiveCompare:)];	

	// Now build thumbnails for each file in the directory (since we can be 
	// confident they'll be built in order)
	NSEnumerator* fileEnum = [myFileList objectEnumerator];
	NSString* file;
	while(file = [fileEnum nextObject])
		if([file isImage])
			[pluginLayer generateThumbnailForFile:file];
	
	// Now let's keep our new list of files.
	[fileList release];
	[myFileList retain];
	fileList = myFileList;
}

@end
