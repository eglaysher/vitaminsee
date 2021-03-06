/////////////////////////////////////////////////////////////////////////
// File:          $URL$
// Module:        Document object for a viewer window.
// Part of:       VitaminSEE
//
// ID:            $Id: ApplicationController.m 123 2005-04-18 00:21:02Z elliot $
// Revision:      $Revision$
// Last edited:   $Date$
// Author:        $Author$
// Copyright:     (c) 2005 Elliot Glaysher
// Created:       8/11/05
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



#import "ApplicationController.h"
#import "ViewerDocument.h"
#import "ComponentManager.h"
#import "ImageLoader.h"
#import "VitaminSEEWindowController.h"
#import "EGPath.h"
#import "NSString+FileTasks.h"
#import "DesktopBackground.h"
#import "FavoritesMenuFactory.h"
#import "Util.h"
#import "FileOperations.h"
#import "RenameFileSheetController.h"
#import "FullscreenWindowController.h"

@implementation ViewerDocument

/** Default initializer. Really calls the initWithPath: initializer with 
 * whatever the default startup path is.
 */
-(id)init
{
	return [self initWithPath:[[NSUserDefaults standardUserDefaults]
		objectForKey:@"DefaultStartupPath"]];
}

//-----------------------------------------------------------------------------

/** Deallocator
 */
-(void)dealloc
{
	NSLog(@"Destroyed!");
//	[window release];
	[documentID release];
	[super dealloc];	
}

-(void)close
{
	NSLog(@"Closing document!");
	
	// Release ourselves from the ApplicationController's list of viewers
	[[ApplicationController controller] remvoeViewerDocument:self];

	id appController = [ApplicationController controller];
	[NSObject cancelPreviousPerformRequestsWithTarget:appController
											 selector:@selector(becomeMainDocument:)
											   object:self];
	
	// Remove ourselves from the ImageLoader. We do this before any other
	// cleanup because there's a race condition where some parts of 
	// ViewerDocument get released while receiveImage: is running...
	[ImageLoader unregisterRequester:self];
	
	documentClosed = YES;
	[currentFile release];
	
	[fileList cleanup];
	[fileList release];
	
	[viewerNotifications release];
	
	[undoManager release];
	
	[super close];
	
	// Release ourselves; we aren't owned by any other object
	[self release];	
}

//-----------------------------------------------------------------------------

/** Initializer that takes a path, creates a normal ViewAsIcons fileList and 
 * displays the incoming path.
 *
 * @param path The directory to display
 */
-(id)initWithPath:(EGPath*)path
{
	if(self = [super init])
	{		
		// Obtain a unique document ID from the Application controller
		documentID = [[ApplicationController controller] getNextAvailableID];
		[documentID retain];
		documentClosed = NO;
		
		// If we say that we have an undo manager, then we 
		[self setHasUndoManager:NO];
		undoManager = [[NSUndoManager alloc] init];
		
		// We need a file list
		fileListName = @"ViewAsIcons";
		fileList = [[ComponentManager getFileListPluginNamed:fileListName] build];
		[fileList setDelegate:self];

		window = [[[VitaminSEEWindowController alloc] initWithFileList:fileList] autorelease];
		[self addWindowController:window];
		[window setShouldCloseDocument:YES];
		viewerNotifications = [[NSNotificationCenter alloc] init];
		
		[window showWindow:window];

		scaleRatio = 1.0f;
		scaleMode = SCALE_IMAGE_TO_FIT;

		[fileList setDirectory:path];
		
		[[ApplicationController controller] addViewerDocument:self];
	}

	return self;
}

//-----------------------------------------------------------------------------

/** Returns the current documentID, a number unique across sessions that 
 * represents this ViewerDocument. This number is used to keep track of which
 * windows request what images by the ImageLoader so that the ImageLoader will
 * cancel old tasks when a new task from the same ViewerDocument is called.
 */
-(NSNumber*)documentID
{
	return documentID;
}

//----------------------------------------------------------------------------- 

/** Used for the Goto Folder method... 
 */
-(void)setDirectoryFromRawPath:(NSString*)path
{
	if([path isDir])  
		[fileList setDirectory:[EGPath pathWithPath:path]];
	else
		AlertSoundPlay();
}

//-----------------------------------------------------------------------------

/** Will set the directory of the FileList if the FileList canSetDirectory.
 */
-(void)setDirectory:(EGPath*)path
{
	if([path isDirectory])
		[fileList setDirectory:path];
	else
		AlertSoundPlay();
}

//-----------------------------------------------------------------------------

/** Focuses on a file in the FileList, and set it as the displayed file. This
 * method is meant to be invoked by objects unrelated to the FileList or the
 * ViewerDocument/VitaminSEEWindowController classes.
 */
-(BOOL)focusOnFile:(EGPath*)path
{	
	// First, we need to make sure we're in the current directory, and move 
	// there if we aren't.
	if([fileList canSetDirectory] &&
	   ![[fileList directory] isEqual:[path pathByDeletingLastPathComponent]])
	{
		[fileList setDirectory:[path pathByDeletingLastPathComponent]];
	}
	
	BOOL ret = [fileList focusOnFile:path];
	[self setDisplayedFileTo:path];
	return ret;
}

//-----------------------------------------------------------------------------

/** Sets the file being displayed. Will spawn a task to the ImageLoader to 
 * load and scale the image. This method is usually called by the current 
 * fileList plugin.
 *
 * @param file EGPath pointing to the file to display.
 */
-(void)setDisplayedFileTo:(EGPath*)file
{
	[file retain];
	[currentFile release];
	currentFile = file;

	// OK, so we're going to cancel any recent becomeMainDocument: message,
	// and then we're going to try to become the main document after a 
	// moment. (So if the user is just holding "down" while scrolling
	// throught the filelist, we aren't going to have slowdowns...)
	id appController = [ApplicationController controller];
	[NSObject cancelPreviousPerformRequestsWithTarget:appController
											 selector:@selector(becomeMainDocument:)
											   object:self];
	[appController performSelector:@selector(becomeMainDocument:)
						withObject:self
						afterDelay:0.15];
	
	// Now tell the actual window to hide that stupid progress spinner.
	[window stopProgressIndicator];
	
	if([[file fileSystemPath] isImage])
	{			
		NSNumber* tag = [[NSUserDefaults standardUserDefaults]
				objectForKey:@"SmoothingTag"];
		id smoothing;
		
		switch([tag intValue]) 
		{
		case 1:
			smoothing = NO_SMOOTHING;
			break;
		case 2:
			smoothing = LOW_SMOOTHING;
			break;
		default:
		case 3:
			smoothing = HIGH_SMOOTHING;
		}
	
		NSMutableDictionary* dic = [NSMutableDictionary 
			dictionaryWithObjectsAndKeys:
				scaleMode, IL_SCALE_MODE,
				[NSNumber numberWithDouble:[window viewingAreaWidth]],
				IL_VIEWING_AREA_WIDTH,
				[NSNumber numberWithDouble:[window viewingAreaHeight]], 
				IL_VIEWING_AREA_HEIGHT,
				smoothing, IL_SMOOTHING,
				[NSNumber numberWithDouble:scaleRatio], IL_SCALE_RATIO,
				currentFile, IL_PATH,
				self, IL_REQUESTER,
			nil];
		
//		NSLog(@"Task dictionary: %@", dic);
		
		[ImageLoader loadTask:dic];
	}
	else 
	{
		// We want to display the folder icon (or whatever it is), since it
		// isn't an image and we want to reflect that.		
		[window setImageSizeLabelText:NSMakeSize(0,0)];
		[window setFileSizeLabelText:-1 forPath:nil];
		[window setZoomStatusBarCellFromTask:nil];
		
		// Display the icon.
		NSImage* image = [file iconImageOfSize:NSMakeSize(128,128)];
		[window setImage:image];
		
		if(pixelWidth == 0)
			pixelWidth = 128;
		if(pixelHeight == 0)
			pixelHeight = 128;
	}
}

//-----------------------------------------------------------------------------

/** Callback method used by the ImageLoader to actually set the image. 
 * ImageLoader is given tasks by the method setDisplayedFileTo:.
 */
-(void)receiveImage:(NSDictionary*)task
{	
//	NSLog(@"Receiving image!");
	// If this is still the current file (i.e., not stale...)
	if([[task objectForKey:IL_PATH]  isEqual:currentFile]) {
		NSImage* image = [task objectForKey:IL_IMAGE];
		
		if(image && !documentClosed) {			
			// Set the image
			[window setImage:image];
			
			pixelWidth = [[task objectForKey:IL_PIXEL_WIDTH] floatValue];
			pixelHeight = [[task objectForKey:IL_PIXEL_HEIGHT] floatValue];				
			
			// Set the image size label
			[window setImageSizeLabelText:NSMakeSize(pixelWidth, pixelHeight)];
			
			// Set the size of the image in bytes
			[window setFileSizeLabelText:[[task objectForKey:IL_DATA_SIZE] intValue]
								 forPath:[task objectForKey:IL_PATH]];

			// Set the zoom data on the status bar
			[window setZoomStatusBarCellFromTask:task];
			
			// If we're in scale mode, update the zoom factor so that if the
			// user zooms in or out, it's relative to the current image.
			scaleRatio = [[task objectForKey:IL_SCALE_RATIO] floatValue];
		}
	}

	// Only stop the progress spinner (and the countdown to display it) if this
	// task message doesn't have a @"Partial" tag on it (since the final results
	// are on the way
	if(![task objectForKey:IL_PARTIAL]) 
		[self stopProgressIndicator];		
	
	[task release];
}

//-----------------------------------------------------------------------------

/** Perform a full redraw event, which will ask the ImageLoader to rescale the
 * iamge.
 */
-(void)redraw
{	
	[self setDisplayedFileTo:currentFile];
}

//-----------------------------------------------------------------------------

-(float)pixelWidth
{
	return pixelWidth;
}

//-----------------------------------------------------------------------------

-(float)pixelHeight
{
	return pixelHeight;
}

//-----------------------------------------------------------------------------

-(NSString*)scaleMode
{
	return scaleMode;
}

//-----------------------------------------------------------------------------
 
/** Returns the current file being displayed.
 */
-(EGPath*)currentFile
{
	return currentFile;
}

//----------------------------------------------------------------------------- 

-(void)beginCountdownToDisplayProgressIndicator
{
	[window beginCountdownToDisplayProgressIndicator];
}

//----------------------------------------------------------------------------- 

-(void)startProgressIndicator
{
	// Pass this message on to the Window
	if(!documentClosed)
		[window startProgressIndicator];
}

//-----------------------------------------------------------------------------
 
-(void)stopProgressIndicator
{
	if(!documentClosed)
		[window stopProgressIndicator];
}

//-----------------------------------------------------------------------------

-(void)updateWindowTitle
{
	if(!documentClosed)
		[window updateWindowTitle];
}

//-----------------------------------------------------------------------------
// FIRST RESPONDER ACTIONS GENERATED BY MENU CLICKS HANDLED BY THIS CLASS.
//-----------------------------------------------------------------------------

/** Validates toolbar items. Everything gets passed on to our generic validator.
 */
-(BOOL)validateToolbarItem:(NSToolbarItem*)toolbarItem
{
	return [self validateAction:[toolbarItem action]];
}

//-----------------------------------------------------------------------------

/** Validates menu items. Most things are just handled by our generic validator,
 * but we also have some menu specific validation that needs to be done.
 */
-(BOOL)validateMenuItem:(NSMenuItem *)anItem
{
	SEL action = [anItem action];
	BOOL enable = [self validateAction:action];	

	// Check to see if we have to change the label on the desktop pictures item.
	if(action == @selector(setAsDesktopImage:))
		enable = [self validateSetAsDesktopImageItem:anItem];
	else if(action == @selector(setFileListFromMenu:))
	{
		// These entries will always be on. The big thing we have to do is
		// check to see if this item should be checked.
		enable = YES;
		
		NSString* name = [anItem representedObject];
		if([fileListName isEqualTo:name])
			[anItem setState:NSOnState];
		else
			[anItem setState:NSOffState];
	}
	else if(action == @selector(becomeFullScreen:))
	{
		if(![[window class] isEqual:[VitaminSEEWindowController class]]) 
			[anItem setState:NSOnState];
		else
			[anItem setState:NSOffState];			
	}
	
	return enable;
}

-(void)setFileListFromMenu:(id)menuItem
{
	NSString* name = [menuItem representedObject];
	if(![name isEqualTo:fileListName])
	{
		// Set the new file here
		// TODO: Make this work.
	}
}

//-----------------------------------------------------------------------------

/** Validate the "Set As Desktop Image" File menu item. 
 */
-(BOOL)validateSetAsDesktopImageItem:(NSMenuItem*)item
{
	BOOL isImage = [currentFile isImage];
	BOOL isDir = [currentFile isDirectory];
	
	BOOL enable = isImage || isDir;
	
	if(isImage)
	{
		[item setTitle:NSLocalizedString(@"Set As Desktop Picture", 
										 @"Text in File menu")];
	}
	else
	{
		[item setTitle:NSLocalizedString(@"Use Folder For Desktop Pictures",
										 @"Text in File menu")];
		
		// Only enable if the folder contains an image
		BOOL containsImage = NO;
		NSArray* directoryContents = [currentFile directoryContents];
		int i = 0, count = [directoryContents count];
		for(; i < count; ++i)
		{
			if([((id)CFArrayGetValueAtIndex((CFArrayRef)directoryContents, i)) isImage])
			{
				containsImage = YES;
				break;
			}
		}
		
		enable = enable && containsImage;
	}	
	
	return enable;
}

//-----------------------------------------------------------------------------

-(BOOL)validateAction:(SEL)action
{
	// Default behaviour: only enable if we respond to this selector.
    BOOL enable = [self respondsToSelector:action];
	
//	NSLog(@"Validating %@ (Is %d)", NSStringFromSelector(action), enable);
	
	// Disable menu items when they would put the image in the state it's 
	// already currently in.
	// File menu
	if(action == @selector(openCurrentItem:))
		enable = [fileList canOpenCurrentItem];
	if(action == @selector(openInPreview:))
		enable = [currentFile isImage];
	else if(action == @selector(moveToTrash:))
		enable = [currentFile isNaturalFile]; //[self validateMoveToTrash];
	else if(action == @selector(addToFavorites:))
		enable = [currentFile isDirectory] && [currentFile isNaturalFile] &&
			!isInFavorites([currentFile fileSystemPath]);
	// View menu
	else if(action == @selector(actualSize:))
		enable = [currentFile isImage] && 
			(scaleMode != SCALE_IMAGE_PROPORTIONALLY || scaleRatio != 1);
	else if(action == @selector(zoomToFit:))
		enable = [currentFile isImage] && scaleMode != SCALE_IMAGE_TO_FIT;
	else if(action == @selector(zoomIn:) ||
			action == @selector(zoomOut:))
		enable = [currentFile isImage];
	else if(action == @selector(revealInFinder:))
		enable = YES;
	// Go menu
	else if(action == @selector(goNextFile:))
		enable = [fileList canGoNextFile];
	else if(action == @selector(goPreviousFile:))
		enable = [fileList canGoPreviousFile];
	else if(action == @selector(goBack:))
		enable = [fileList canGoBack];
	else if(action == @selector(goForward:))
		enable = [fileList canGoForward];
	else if(action == @selector(goEnclosingFolder:))
		enable = [fileList canGoEnclosingFolder];
	
	return enable;
}

//-----------------------------------------------------------------------------

/** This is a high level TODO!
 *
 */
-(BOOL)validateMoveToTrash
{
	BOOL ok = YES;
//	NSFileManager* fm = [NSFileManager defaultManager];
	
	// If our user doesn't have +w on the current folder, set ok to NO.
//	unsigned long folderPermissions = [fm fileAttributesAtPath:<#(NSString *)path#>
//												  traverseLink:NO];
	
	// If our user doesn't have +w on the current file, set ok to NO.
//	unsigned long filePermissions = [fm fileAttributesAtPath:<#(NSString *)path#>
//												traverseLink:NO];
	
	// FIXME HERE! Detect 
	
	return ok;
}

//-----------------------------------------------------------------------------

/** Redefine undoManager. The NSDocument object also has support to own an
 * NSUndoManager object, but it then observes that object to set the NSDocument
 * dirty bit, which marks the proxy icon and the close button. On Panther, this
 * also has the undesierable effect of forcing a Don't Save/Cancel/Save dialog
 * when the window is closed. So instead, mark -setHasUndoManager:NO in the
 * constructor, and override this method so that it returns the ViewerDocument
 * owned NSUndoManager.
 */
-(NSUndoManager*)undoManager
{
	return undoManager;
}

//-----------------------------------------------------------------------------
// FILE MENU
//-----------------------------------------------------------------------------

/** Function invoked when File > Open is activated. This function should go into
* the currently selected directory, though different FileLists may have 
* different semantics.
*/
-(void)openCurrentItem:(id)sender
{
	[fileList openCurrentItem];
}

//-----------------------------------------------------------------------------

/** Opens the current image in Preview
*/
-(void)openInPreview:(id)sender
{
	[[NSWorkspace sharedWorkspace]	openFile:[currentFile fileSystemPath]
							 withApplication:@"Preview"];
}

//-----------------------------------------------------------------------------

// ***  Open With handled in Application Controller

//-----------------------------------------------------------------------------

/** Cause the rename dialog to display
 */
-(void)renameFile:(id)sender
{
	id fileop = [ComponentManager getInteranlComponentNamed:@"FileOperations"];
	id controller = [fileop buildRenameSheetController];
	[controller showSheet:[window window] 
			 initialValue:currentFile
		   notifyWhenDone:self];
}

//-----------------------------------------------------------------------------

/** Add the current directory to the favorites.
 */
-(void)addToFavorites:(id)sender
{
	NSString* filepath = [currentFile fileSystemPath];
	
	id favoritesComponent = [ComponentManager
		getInteranlComponentNamed:@"FavoritesMenu"];
	[favoritesComponent addDirectoryToFavorites:filepath];
}

//-----------------------------------------------------------------------------

/** Sets the current selection {file, directory} as the desktop image.
 */
-(void)setAsDesktopImage:(id)sender
{
	id desktopBackground = [ComponentManager 
		getInteranlComponentNamed:@"DesktopBackground"];
	
	if([currentFile isImage])
		[desktopBackground setDesktopBackgroundToFile:[currentFile fileSystemPath]];
	else if([currentFile isDirectory])
		[desktopBackground setDesktopBackgroundToFolder:[currentFile fileSystemPath]];	
}

//-----------------------------------------------------------------------------

/** Deletes the file
 */
-(void)moveToTrash:(id)sender
{
	[[ComponentManager getInteranlComponentNamed:@"FileOperations"]
		deleteFile:currentFile];
}

//-----------------------------------------------------------------------------
// VIEW MENU
//-----------------------------------------------------------------------------

/** Scales the image so there is one pixel in the image is one pixel on screen.
 */
-(void)actualSize:(id)sender
{
	scaleMode = SCALE_IMAGE_PROPORTIONALLY;
	scaleRatio = 1.0f;
	[self setDisplayedFileTo:currentFile];
}

//-----------------------------------------------------------------------------

/** Zooms in on the image. 
 */
-(void)zoomIn:(id)sender
{
	scaleMode = SCALE_IMAGE_PROPORTIONALLY;
	scaleRatio += 0.10f;
	[self setDisplayedFileTo:currentFile];	
}

//-----------------------------------------------------------------------------

/** Zooms out from the image. 
 */
-(void)zoomOut:(id)sender
{
	scaleMode = SCALE_IMAGE_PROPORTIONALLY;
	scaleRatio -= 0.10f;
	[self setDisplayedFileTo:currentFile];
}

//-----------------------------------------------------------------------------

/** Scales the image so that it fits perfectly in the window. 
 */
-(void)zoomToFit:(id)sender
{
	scaleMode = SCALE_IMAGE_TO_FIT;
	scaleRatio = 1.0f;
	[self setDisplayedFileTo:currentFile];
}

//-----------------------------------------------------------------------------

/** Reveals the current file in the Finder.
 */
-(void)revealInFinder:(id)sender
{
	[[NSWorkspace sharedWorkspace] selectFile:[currentFile fileSystemPath]
					 inFileViewerRootedAtPath:@""];
}


/** Switch between fullscreen and not.
 */
-(void)becomeFullScreen:(id)sender
{
	if([[window class] isEqual:[VitaminSEEWindowController class]])
	{
		[window setShouldCloseDocument:NO];

		// Make all the document windows hide, recording their current state
		// so we can restore it later
		previousVisibleState = [[NSMutableArray alloc] init];
		id otherDocuments = [[ApplicationController controller] viewerDocuments];
		NSEnumerator* e = [otherDocuments objectEnumerator];
		id curDocument;
		while(curDocument = [e nextObject]) 
		{
			if(curDocument != self) {
				NSWindow* curWindow = [[[curDocument windowControllers] objectAtIndex:0] window];
				[previousVisibleState addObject:curWindow];
				[curWindow orderOut:self];				
			}
		}
		
		// Alert the application controller that we are now fullscreen
		[[ApplicationController controller] setFullScreenDocument:self];
		
		// Become fullscreen
		id old = window;
		windowLocation = [[old window] frame];
		window = [[[ComponentManager getInteranlComponentNamed:@"FullScreenMode"]
			build] autorelease];
		[self addWindowController:window];
		[window setFileList:fileList];
		[window becomeFullscreen];
		[self redraw];
		[old close];
	}
	else
	{
		// Leave fullscreen
		NSWindowController* old = window;

		// Now restore all the other windows
		NSEnumerator* e = [previousVisibleState objectEnumerator];
		id curWindow;
		while(curWindow = [e nextObject]) 
		{
			[curWindow orderFront:self];
		}
		
		// Recreate the real VitaminSEE window.
		window = [[[VitaminSEEWindowController alloc] initWithFileList:fileList] autorelease];
		[self addWindowController:window];		
		[[window window] setFrame:windowLocation display:NO];
		[window setFileList:fileList];
		[window updateWindowTitle];
		
		[[window window] makeKeyAndOrderFront:self];
		[self redraw];
		[old close];
		[window setShouldCloseDocument:YES];

		// Alert the application controller that we are not fullscreen anymore
		[[ApplicationController controller] setFullScreenDocument:nil];
		
		// Now redisplay the file list
		[fileList makeFirstResponderTo:[window window]];
	}
}

//-----------------------------------------------------------------------------
// GO MENU
//-----------------------------------------------------------------------------

/** Go Next
 */
-(void)goNextFile:(id)sender
{
	[fileList goNextFile];
}

//-----------------------------------------------------------------------------

/** Go Previous
 */
-(void)goPreviousFile:(id)sender
{
	[fileList goPreviousFile];
}

//-----------------------------------------------------------------------------

/** Go Back
 */
-(void)goBack:(id)sender
{
	[fileList goBack];
}

//-----------------------------------------------------------------------------

/** Go Forward
 *
 */
-(void)goForward:(id)sender
{
	[fileList goForward];
}

//-----------------------------------------------------------------------------

/** Go Enclosing Folder
 *
 */
-(void)goEnclosingFolder:(id)sender
{
	[fileList goEnclosingFolder];
}

@end
