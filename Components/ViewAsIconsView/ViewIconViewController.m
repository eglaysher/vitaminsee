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
#import "EGPath.h"

@interface ViewIconViewController (Private)
-(void)rebuildInternalFileArray;
-(void)handleDidMountNotification:(id)notification;
-(void)handleDidUnmountNotification:(id)notification;
@end

@implementation ViewIconViewController

-(id)initWithPluginLayer:(PluginLayer*)inPluginLayer
{
	if(self = [super init])
	{
		[NSBundle loadNibNamed:@"ViewAsIconsView" owner:self];

		[inPluginLayer retain];
		pluginLayer = inPluginLayer;

		oldPosition = -1;
		
		// Register for mounting/unmounting notifications
		NSNotificationCenter* nc = [[NSWorkspace sharedWorkspace] notificationCenter];
		[nc addObserver:self 
			   selector:@selector(handleDidMountNotification:)
				   name:NSWorkspaceDidMountNotification
				 object:nil];
		[nc addObserver:self
			   selector:@selector(handleDidUnmountNotification:)
				   name:NSWorkspaceDidUnmountNotification
				 object:nil];		
	}

	return self;
}

-(void)dealloc
{
	// Unregister for notifications
	NSNotificationCenter* nc = [[NSWorkspace sharedWorkspace] notificationCenter];
	[nc removeObserver:self];
	
	[pluginLayer release];
	[super dealloc];
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

-(void)connectKeyFocus:(id)nextFocus
{
	[directoryDropdown setNextKeyView:ourBrowser];
	[ourBrowser setNextKeyView:nextFocus];
	[nextFocus setNextKeyView:directoryDropdown];	
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

- (void)setCurrentDirectory:(EGPath*)newCurrentDirectory
				currentFile:(NSString*)newCurrentFile
{	
	[pluginLayer startProgressIndicator];
	
	assert(![newCurrentDirectory isKindOfClass:[NSString class]]);
	
	if(currentDirectory && newCurrentDirectory && 
	   ![currentDirectory isEqual:newCurrentDirectory])
		[[[pluginLayer pathManager] prepareWithInvocationTarget:self]
			setCurrentDirectory:currentDirectory
					currentFile:[pluginLayer currentFile]];

	// Clear the thumbnails. They need to be regenerated...
	[pluginLayer clearThumbnailQueue];
	
	// Set the current Directory
	[currentDirectory release];
	currentDirectory = [newCurrentDirectory retain];
	
	// We need the display names to present to the user.
	NSArray* displayNames = [currentDirectory pathDisplayComponents];
	NSArray* paths = [currentDirectory pathComponents];
	
	// Make an NSMenu with all the path components
	NSMenu* newMenu = [[[NSMenu alloc] init] autorelease];	
	unsigned count = [paths count];
	unsigned i;
	for(i = 0; i < count; ++i)
	{
		NSMenuItem* newMenuItem = [[[NSMenuItem alloc] 
			initWithTitle:[displayNames objectAtIndex: count - i - 1]
				   action:@selector(directoryMenuSelected:)
			keyEquivalent:@""] autorelease];
		
		id currentPathRep = [paths objectAtIndex:count - i - 1];

		// Only load the image for the currently displayed image, since this
		// is the only one that is initially displayed. Set the others in the
		// validation method.
		if(i == 0)
		{
			NSImage* img = [currentPathRep fileIcon];
			[img setScalesWhenResized:YES];
			[img setSize:NSMakeSize(16,16)];
			[newMenuItem setImage:img];
		}

		[newMenuItem setRepresentedObject:currentPathRep];
		[newMenuItem setTarget:self];
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
	
	[[ourBrowser window] makeFirstResponder:ourBrowser];
}

-(BOOL)validateMenuItem:(NSMenuItem *)theMenuItem
{
	// Set up the image for this menu item if we haven't already assigned an
	// image.
	if(![theMenuItem image])
	{
		NSImage* image = [[theMenuItem representedObject] fileIcon];
		[image setScalesWhenResized:YES];
		[image setSize:NSMakeSize(16,16)];
		[theMenuItem setImage:image];
	}
	return YES;
}

-(void)directoryMenuSelected:(id)sender
{
	id path = [sender representedObject];
	[self setCurrentDirectory:path
				  currentFile:nil];
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
	NSString* path = [fileList objectAtIndex:row];
	[cell setCellPropertiesFromPath:path];
	[cell setIconImage:[path iconImageOfSize:NSMakeSize(128,128)]];
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

-(void)singleClick:(id)sender
{
	// grab the image path
	int index = [[ourBrowser matrixInColumn:0] selectedRow];
	if(index == -1)
		return;
	
	NSString* absolutePath = [fileList objectAtIndex:index];

	[pluginLayer setCurrentFile:absolutePath];
	
	if(NSAppKitVersionNumber < 824.00f)
	{
		// Hi! My name is UGLY HACK. I'm here because Apple's NSScrollView has a
		// subtle bug about the areas needed to visually redrawn, so we have to 
		// redisplay THE WHOLE ENCHILADA when we scroll since there's a 1/5~ish
		// chance that the location where the top image cell would be will be the 
		// target drawing location of two or three cells.
		//
		// Thankfully, this was fixed in Tiger. But Tiger didn't give us an f'in
		// AppKit version number for it.
		[ourBrowser setNeedsDisplay];
	}
	
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

-(void)doubleClick:(id)sender
{
	// Double clicking sets the directory...if it's a directory
	NSString* absolutePath = [fileList objectAtIndex:[[ourBrowser matrixInColumn:0] selectedRow]];
	
	if([absolutePath isDir])
		// Get the first image in the directory:		
		[self setCurrentDirectory:[pluginLayer pathWithPath:absolutePath] currentFile:nil];
}

-(void)removeFile:(NSString*)absolutePath
{
	unsigned index = [fileList binarySearchFor:absolutePath 
		withSortSelector:@selector(caseInsensitiveCompare:)];

	NSMatrix* matrix = [ourBrowser matrixInColumn:0];
	NSString* newFile = 0;
	if(index != NSNotFound)
	{
		if(index == [matrix selectedRow])
			newFile = [self nameOfNextFile];

		[fileList removeObjectAtIndex:index];
		
		[ourBrowser loadColumnZero];
		
		[ourBrowser setNeedsDisplay];
		
		// Set the next file
		if(newFile)
		{
			[self selectFile:newFile];
			[pluginLayer setCurrentFile:newFile];			
		}
		else if([fileList count] == 0)
			[pluginLayer setCurrentFile:nil];
		else
			[self selectFile:[pluginLayer currentFile]];
	}
}

-(void)addFile:(NSString*)path
{
	if([[currentDirectory fileSystemPath] isEqual:[path stringByDeletingLastPathComponent]])
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
	NSString* currentFile = [pluginLayer currentFile];
	NSString* nextFile;

	int index = [fileList binarySearchFor:currentFile 
							  withSortSelector:@selector(caseInsensitiveCompare:)];
	int count = [fileList count];
	
	if(index == NSNotFound)
		nextFile = nil;
	else if(index + 1 < count)
		nextFile = [fileList objectAtIndex:(index + 1)];
	else if(index - 1 >= 0)
		nextFile = [fileList objectAtIndex:(index - 1)];
	else
		nextFile = nil;

	return nextFile;
}

-(void)selectFile:(NSString*)fileToSelect
{
	if(fileToSelect)
		[ourBrowser setPath:[NSString pathWithComponents:[NSArray arrayWithObjects:
			@"/", [fileToSelect lastPathComponent], nil]]];
}

-(void)makeFirstResponderTo:(NSWindow*)window
{
	[window makeFirstResponder:ourBrowser];
}

-(void)setThumbnail:(NSImage*)image forFile:(NSString*)path
{
	unsigned index = [fileList binarySearchFor:path
							  withSortSelector:@selector(caseInsensitiveCompare:)];
	if(index != NSNotFound)
	{
		[[ourBrowser loadedCellAtRow:index column:0] setIconImage:image];
		[ourBrowser setNeedsDisplay];
	}
}

-(BOOL)canGoEnclosingFolder
{
	return [[currentDirectory pathDisplayComponents] count] > 1;
}

-(void)goEnclosingFolder
{
	NSArray* paths = [currentDirectory pathComponents];
	EGPath* currentDirCopy = [currentDirectory retain];
	// fixme: Possible problem
	[self setCurrentDirectory:[paths objectAtIndex:[paths count] - 2]
				  currentFile:[currentDirCopy fileSystemPath]];
	[currentDirCopy release];
}

-(BOOL)canGoNextFile 
{
	int index = [fileList binarySearchFor:[pluginLayer currentFile]
						 withSortSelector:@selector(caseInsensitiveCompare:)];
	
	int count = [fileList count];
	if(index < count - 1)
		return YES;
	else
		return NO;
}

-(void)goNextFile
{
	int index = [fileList binarySearchFor:[pluginLayer currentFile]
						 withSortSelector:@selector(caseInsensitiveCompare:)];
	index++;
	
	// Select this file
	[ourBrowser selectRow:index inColumn:0];
	[self singleClick:ourBrowser];
}

-(BOOL)canGoPreviousFile
{
	int index = [fileList binarySearchFor:[pluginLayer currentFile]
						 withSortSelector:@selector(caseInsensitiveCompare:)];

	if(index > 0)
		return YES;
	else
		return NO;
}

-(void)goPreviousFile
{
	int index = [fileList binarySearchFor:[pluginLayer currentFile]
						 withSortSelector:@selector(caseInsensitiveCompare:)];
	index--;
	
	// Select this file
	[ourBrowser selectRow:index inColumn:0];
	[self singleClick:ourBrowser];
}

@end

@implementation ViewIconViewController (Private)

-(void)rebuildInternalFileArray
{
	NSArray* directoryContents = [currentDirectory directoryContents];
	NSEnumerator* dirEnum = [directoryContents objectEnumerator];
	NSMutableArray* myFileList = [NSMutableArray arrayWithCapacity:[directoryContents count]];
	EGPath* curPath;
	while(curPath = [dirEnum nextObject])
	{
		NSString* currentFileWithPath = [curPath fileSystemPath];
				
		if(([currentFileWithPath isDir] || [currentFileWithPath isImage]) &&
		   [currentFileWithPath isVisible])
		{
			// Before we  do ANYTHING, we make note of the file's modification time.
			[myFileList addObject:currentFileWithPath];
		}
	}
	
	// Now sort the list since some filesystems (*cough*SAMBA*cough*) don't
	// present files sorted alphabetically and we do binary searches to avoid
	// O(n) overhead later on.
	[myFileList sortUsingSelector:@selector(caseInsensitiveCompare:)];	

	// Now build thumbnails for each file in the directory (since we can be 
	// confident they'll be built in order)
	// 
	// fixme: future optimization: add something to the thumbnail manager/plugin
	// layer that allows you just send an NSArray to it. This would save
	// [cost of message dispatch] * 3 * (numberOfFilesInDirectory)...
	// This wouldn't be worthless since shark says 25% of the time in this 
	// function is here.
	NSEnumerator* fileEnum = [myFileList objectEnumerator];
	NSString* file;
	while(file = [fileEnum nextObject])
		if([file isImage])
			[pluginLayer generateThumbnailForFile:file];
	
	// Now let's keep our new list of files.
	[myFileList retain];
	[fileList release];	
	fileList = myFileList;

//	NSLog(@"filelist retain count: %d", [fileList retainCount]);
}

// Handle notifications
-(void)handleDidMountNotification:(id)notification
{
	if([currentDirectory isRoot])
	{	
		// Rebuild list to reflect the mounted drive since we're in machine root.
		[self rebuildInternalFileArray];
		[ourBrowser loadColumnZero];
		[ourBrowser selectRow:0 inColumn:0];
		[self singleClick:ourBrowser];		
	}
}

-(void)handleDidUnmountNotification:(id)notification
{
	NSString* unmountedPath = [[notification userInfo] objectForKey:@"NSDevicePath"];

	if([currentDirectory isRoot])
	{
		// Rebuild list to reflect the mounted drive since we're in machine root.
		[self rebuildInternalFileArray];
		[ourBrowser loadColumnZero];
		[ourBrowser selectRow:0 inColumn:0];
		[self singleClick:ourBrowser];		
	}
	else if([[currentDirectory fileSystemPath] hasPrefix:unmountedPath])
	{
		// Drop back to root
		[self setCurrentDirectory:[[currentDirectory pathComponents] objectAtIndex:0]
					  currentFile:nil];
	}
}

@end
