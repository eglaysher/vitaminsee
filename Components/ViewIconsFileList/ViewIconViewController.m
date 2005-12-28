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
// This program is free software; you can redistribute it and/or
// modify it under the terms of the GNU General Public License
// as published by the Free Software Foundation; either version 2
// of the License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program; if not, write to the Free Software
// Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
//
////////////////////////////////////////////////////////////////////////

#import "AppKitAdditions.h"
#import "ViewIconViewController.h"
#import "ViewIconsCell.h"
#import "NSString+FileTasks.h"
#import "FileList.h"
#import "EGPath.h"
#import "ImageLoader.h"
#import "ThumbnailManager.h"

#import "UKKQueue.h"

@interface ViewIconViewController (Private)
-(void)rebuildInternalFileArray;
-(void)handleDidMountNotification:(id)notification;
-(void)handleWillUnmountNotification:(id)notification;
-(void)handleDidUnmountNotification:(id)notification;
@end

@implementation ViewIconViewController

-(id)init
{
	if(self = [super init])
	{
		// ViewIconsFileView
		[NSBundle loadNibNamed:@"ViewIconsFileView" owner:self];

		oldPosition = -1;
		
		// Register for mounting/unmounting notifications
		NSNotificationCenter* nc = [[NSWorkspace sharedWorkspace] notificationCenter];
		[nc addObserver:self 
			   selector:@selector(handleDidMountNotification:)
				   name:NSWorkspaceDidMountNotification
				 object:nil];
		[nc addObserver:self
			   selector:@selector(handleWillUnmountNotification:)
				   name:NSWorkspaceWillUnmountNotification
				 object:nil];
		[nc addObserver:self
			   selector:@selector(handleDidUnmountNotification:)
				   name:NSWorkspaceDidUnmountNotification
				 object:nil];	
		
		needToRebuild = NO;

		pathManager = [[NSUndoManager alloc] init];
		fileWatcher = [[UKKQueue alloc] init];
		[fileWatcher setDelegate:self];
	}

	return self;
}

-(void)dealloc
{
	// Unregister for notifications
	NSNotificationCenter* nc = [[NSWorkspace sharedWorkspace] notificationCenter];
	[nc removeObserver:self];
	
	[fileWatcher release];
	[pathManager release];
	[super dealloc];
}

-(void)setDelegate:(id<FileListDelegate>)newDelegate
{
	delegate = newDelegate;
}

-(id<FileListDelegate>)delegate
{
	return delegate;
}

-(void)awakeFromNib
{
	[ourBrowser setTarget:self];
	[ourBrowser setAction:@selector(singleClick:)];
	[ourBrowser setDoubleAction:@selector(doubleClick:)];	
	[ourBrowser setCellClass:[ViewIconsCell class]];
	[ourBrowser setDelegate:self];
	
	[ourBrowser setReusesColumns:NO];
	
	currentlySelectedCell = nil;
}

-(void)connectKeyFocus:(id)nextFocus
{
	[directoryDropdown setNextKeyView:ourBrowser];
	[ourBrowser setNextKeyView:nextFocus];
	[nextFocus setNextKeyView:directoryDropdown];	
}

//////////////////////////////////////////////////////////// PROTOCOL: FileView

-(BOOL)canSetDirectory
{
	return YES;
}

- (BOOL)setDirectory:(EGPath*)newCurrentDirectory
{	
//	[pluginLayer flushImageCache];
	
	// First subscribe to the new directory.
	[ThumbnailManager subscribe:self toDirectory:newCurrentDirectory];

	if(currentDirectory) 
	{
		[pathManager registerUndoWithTarget:self
								   selector:@selector(setDirectory:)
									 object:currentDirectory];
		[pathManager registerUndoWithTarget:self 
								   selector:@selector(focusOnFile:) 
									 object:currentFile];		
		
		// Stop watching this directory if it's something kqueue will alert us
		// about.
		if([currentDirectory isNaturalFile]) 
		{
			[fileWatcher removePath:[currentDirectory fileSystemPath]];
		}
		
		// Note that we unsubscribe from the old directory after 
		[ThumbnailManager unsubscribe:self fromDirectory:currentDirectory];
	}
	
	if([newCurrentDirectory isNaturalFile])
		[fileWatcher addPath:[newCurrentDirectory fileSystemPath]];

	// Clear the thumbnails. They need to be regenerated...
	// FIXME: Update
//	[pluginLayer clearThumbnailQueue];
	
	// Set the current Directory
	[newCurrentDirectory retain];
	[currentDirectory release];
	currentDirectory = newCurrentDirectory;
	
	// We need the display names to present to the user.
	NSArray* displayNames = [currentDirectory pathDisplayComponents];
	NSArray* paths = [currentDirectory pathComponents];
	
	// Make an NSMenu with all the path components
	NSMenu* newMenu = [[[NSMenu alloc] init] autorelease];	
	unsigned count = [paths count];
	unsigned i;
	for(i = 0; i < count; ++i)
	{
		NSString* menuPathComponentName = [displayNames objectAtIndex: count - i - 1];
		NSMenuItem* newMenuItem = [[[NSMenuItem alloc] 
			initWithTitle:menuPathComponentName
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
	[ourBrowser setCellClass:[ViewIconsCell class]];
//	[ourBrowser setSendsActionOnArrowKeys:NO];
	[ourBrowser loadColumnZero];
	
	// Select the first file on the list
	[ourBrowser selectRow:0 inColumn:0];
	[self singleClick:ourBrowser];
	
	[[ourBrowser window] makeFirstResponder:ourBrowser];
	
	return YES;
}

//-----------------------------------------------------------------------------

-(BOOL)focusOnFile:(EGPath*)file
{
	NSLog(@"Egpath: '%@'", file);
	unsigned index = [fileList binarySearchFor:[file fileSystemPath]
							  withSortSelector:@selector(caseInsensitiveCompare:)];

	if(index != NSNotFound)
	{
		[ourBrowser selectRow:index inColumn:0];
		return YES;
	}
	else 
	{
		return NO;
	}
}

//-----------------------------------------------------------------------------

/** Validator for the menu items in the directory drop down. Loads the file 
 * icon for each item if it hasn't been loaded already.
 */
-(BOOL)validateMenuItem:(NSMenuItem *)theMenuItem
{
	if(![theMenuItem image])
	{
		NSImage* image = [[theMenuItem representedObject] fileIcon];
		[image setScalesWhenResized:YES];
		[image setSize:NSMakeSize(16,16)];
		[theMenuItem setImage:image];
	}
	return YES;
}

//-----------------------------------------------------------------------------

/** Callback method that gets called when a directory is selected from the 
 * drop-down
 */
-(void)directoryMenuSelected:(id)sender
{
	id path = [sender representedObject];
	[self setDirectory:path];
}

-(NSView*)getView
{
	return ourView;
}


//-----------------------------------------------------------------------------
-(void)openCurrentItem
{
	NSLog(@"-[ViewIconViewController openCurrentItem]");
	[self doubleClick:self];
}

-(BOOL)canOpenCurrentItem
{
	return [currentFile isDirectory];
}
//-----------------------------------------------------------------------------
//------------------------------------------------------------ BROWSER DELEGATE
//-----------------------------------------------------------------------------

/** Returns the number of items in the current directory, which is used by the
 * NSBrowser for lazy loading.
 */
- (int)browser:(NSBrowser *)sender numberOfRowsInColumn:(int)column
{
	return [fileList count];
}

//-----------------------------------------------------------------------------

/** Delegate method used to initialize each cell in the browser right before
 * it's displayed.
 */
- (void)browser:(NSBrowser *)sender 
willDisplayCell:(id)cell 
		  atRow:(int)row 
		 column:(int)column
{
	NSString* path = [fileList objectAtIndex:row];
	// FIXME
	[cell setCellPropertiesFromPath:path andEGPath:
		[NSClassFromString(@"EGPath") pathWithPath:path]];
	
	// If the cell image hasn't been loaded
	if(![cell iconImage])
	{
		// If there's an entry in the thumbnail cache, use it
		NSImage* icon = [ThumbnailManager getThumbnailFor:[NSClassFromString(@"EGPath") pathWithPath:path]];
		
		// If there isn't, use the file icon...
		if(!icon)
			icon = [path iconImageOfSize:NSMakeSize(128,128)];

//		[self removeUnneededImageReps:icon];
		[cell setIconImage:icon];
	}
}

//-----------------------------------------------------------------------------

/** Handles a single click, displays an image.
 */
-(void)singleClick:(id)sender
{	
	// grab the image path
	int index = [[ourBrowser matrixInColumn:0] selectedRow];
	if(index == -1)
		return;
	
	NSString* absolutePath = [fileList objectAtIndex:index];

	[delegate setDisplayedFileTo:[EGPath pathWithPath:absolutePath]];

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
		// FIXME
		if(node && [node isImage])
			[ImageLoader preloadImage:[EGPath pathWithPath:node]];
	}

	oldPosition = newPosition;
}

//-----------------------------------------------------------------------------

/** Double clicking changes the current directory
 */
-(void)doubleClick:(id)sender
{
	// Double clicking sets the directory...if it's a directory
	NSString* absolutePath = [fileList objectAtIndex:[[ourBrowser matrixInColumn:0] selectedRow]];

	// FIXME
	if([absolutePath isDir])
//		// Get the first image in the directory:		
		[self setDirectory:[EGPath pathWithPath:absolutePath]];
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

-(void)receiveThumbnail:(NSImage*)image forFile:(EGPath*)path
{
	[self setThumbnail:image forFile:[path fileSystemPath]];
}

-(void)setThumbnail:(NSImage*)image forFile:(NSString*)path
{
	unsigned index = [fileList binarySearchFor:path
							  withSortSelector:@selector(caseInsensitiveCompare:)];
	if(index != NSNotFound)
	{
		id currentCell = [[ourBrowser matrixInColumn:0] cellAtRow:index column:0];

//		[self removeUnneededImageReps:image];
		
		if([currentCell isLoaded])
		{
			[currentCell setIconImage:image];
			[ourBrowser setNeedsDisplay];
		}		
	}
}

// We  don't need image representations that aren't the 128 version. Junk them.
-(void)removeUnneededImageReps:(NSImage*)image
{
	int pixelsHigh, pixelsWide, longSide;
	NSArray* imageReps = [image representations];
	NSEnumerator* e = [imageReps objectEnumerator];
	NSImageRep* rep;
	while(rep = [e nextObject])
	{
		pixelsHigh = [rep pixelsHigh];
		pixelsWide = [rep pixelsWide];
		longSide = pixelsHigh > pixelsWide ? pixelsHigh : pixelsWide;
		
		if(longSide != 128)
			[image removeRepresentation:rep];
	}	
}

//-----------------------------------------------------------------------------

-(BOOL)canGoEnclosingFolder
{
	return [[currentDirectory pathDisplayComponents] count] > 1;
}

//-----------------------------------------------------------------------------

-(void)goEnclosingFolder
{
	NSArray* paths = [currentDirectory pathComponents];
	EGPath* currentDirCopy = [currentDirectory retain];
	[self setDirectory:[paths objectAtIndex:[paths count] - 2]];
	[self focusOnFile:currentDirCopy];
	[currentDirCopy release];
}

//-----------------------------------------------------------------------------

-(BOOL)canGoNextFile 
{
	int index = [fileList binarySearchFor:[[delegate currentFile] fileSystemPath]
						 withSortSelector:@selector(caseInsensitiveCompare:)];
	
	int count = [fileList count];
	if(index < count - 1)
		return YES;
	else
		return NO;
}

//-----------------------------------------------------------------------------

-(void)goNextFile
{
	int index = [fileList binarySearchFor:[[delegate currentFile] fileSystemPath]
						 withSortSelector:@selector(caseInsensitiveCompare:)];
	index++;
	
	// Select this file
	[ourBrowser selectRow:index inColumn:0];
	[self singleClick:ourBrowser];
}

//-----------------------------------------------------------------------------

-(BOOL)canGoPreviousFile
{
	int index = [fileList binarySearchFor:[[delegate currentFile] fileSystemPath]
						 withSortSelector:@selector(caseInsensitiveCompare:)];

	if(index > 0)
		return YES;
	else
		return NO;
}

//-----------------------------------------------------------------------------

-(void)goPreviousFile
{
	int index = [fileList binarySearchFor:[[delegate currentFile] fileSystemPath]
						 withSortSelector:@selector(caseInsensitiveCompare:)];
	index--;
	
	// Select this file
	[ourBrowser selectRow:index inColumn:0];
	[self singleClick:ourBrowser];
}

//-----------------------------------------------------------------------------

-(BOOL)canGoBack
{
	return [pathManager canUndo];
}

//-----------------------------------------------------------------------------

-(void)goBack
{
	[pathManager undo];
}

//-----------------------------------------------------------------------------

-(BOOL)canGoForward
{
	return [pathManager canRedo];
}

//-----------------------------------------------------------------------------

-(void)goForward
{
	[pathManager redo];
}

//-----------------------------------------------------------------------------

-(EGPath*)directory
{
	return currentDirectory;
}

//-----------------------------------------------------------------------------

-(EGPath*)file
{
	return currentFile;
}

//-----------------------------------------------------------------------------

-(void)setWindowTitle:(NSWindow*)window
{
	// For now, do nothing.
}

@end

@implementation ViewIconViewController (Private)

-(void)rebuildInternalFileArray
{
//	NSLog(@"-[ViewIconViewController(Private) rebuildInternalFileArray]");
	NSArray* directoryContents = [currentDirectory directoryContents];
	NSMutableArray* myFileList = [[NSMutableArray alloc] initWithCapacity:
		[directoryContents count]];

	int i = 0, count = [directoryContents count];
	for(; i < count; ++i)
	{
		EGPath* curPath = (id)CFArrayGetValueAtIndex((CFArrayRef)directoryContents, i);
		NSString* currentFileWithPath = [curPath fileSystemPath];
		
		if(([curPath isDirectory] || [currentFileWithPath isImage]) &&
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
	// FIXME
	// When I fix this, make sure to use -[NSArray makeObjectsPerformSelector:withObject:]...
	//	[pluginLayer performSelector:@selector(generateThumbnailForFile:)
//				withEachObjectIn:myFileList];
	
	// Now let's keep our new list of files. (Note it was allocated earlier)
	[fileList release];	
	fileList = myFileList;
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

-(void)handleWillUnmountNotification:(id)notification
{
	@try
	{
		NSString* unmountedPath = [[notification userInfo] objectForKey:
			@"NSDevicePath"];
		NSString* realPath = [[currentDirectory fileSystemPath] 
			stringByResolvingSymlinksInPath];

		// Detect if we are on the volume that's going to be unmounted. We have
		// to do this before the volume is unmounted, since otherwise the
		// symlink isn't going to be detected
		if([realPath hasPrefix:unmountedPath])
		{
			// Trying to modify stuff here takes locks on the files on the 
			// remote volume. So take note that we HAVE to drop back to root.
			needToRebuild = YES;
		}
	}
	@catch(NSException *exception)
	{
		// If there was a selector not found error, then it came from 
		// [currentDirecoty fileSystemPath], which may be and EGPathRoot and 
		// not have a real path...
		NSLog(@"*** Non-critical exception. Ignore previous -[EGPathRoot fileSystemPath]: message.");
	}
}

-(void)handleDidUnmountNotification:(id)notification
{
	NSString* unmountedPath = [[notification userInfo] objectForKey:
		@"NSDevicePath"];
	
	if(needToRebuild || [currentDirectory isRoot] || 
	   [[currentDirectory fileSystemPath] hasPrefix:unmountedPath])
	{
		// Rebuild list to reflect the mounted drive since we're in machine root.
		[self setDirectory:[[currentDirectory pathComponents] objectAtIndex:0]];
	}
	
	needToRebuild = NO;
}


//-----------------------------------------------------------------------------

/** Delegate function for UKKQueue. 
 *
 */
-(void) watcher: (id<UKFileWatcher>)kq receivedNotification: (NSString*)nm 
		forPath: (NSString*)fpath
{
	NSLog(@"Notification: '%@' for '%@'", nm, fpath);
	
	if([currentDirectory isNaturalFile]) 
	{
		EGPath* curFile = [[delegate currentFile] retain];
		
		// Update the filelist, tell the browser to reload its data, and then
		// set the file back to the current file.
		
		[self rebuildInternalFileArray];
		
		oldPosition = -1;
		
		// Now reload the data
		[ourBrowser setCellClass:[ViewIconsCell class]];
		//	[ourBrowser setSendsActionOnArrowKeys:NO];
		[ourBrowser loadColumnZero];
		
		// Focus on the file we were focused on before.
		if(![self focusOnFile:curFile]) 
		{
			// If we can't focus on the same file as before, then that means
			// we got rid of the file we're currently viewing; and we need to
		}
		
		[curFile release];
	}
}

@end
