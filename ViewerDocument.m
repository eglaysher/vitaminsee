//
//  ViewerDocument.m
//  Prototype
//
//  Created by Elliot Glaysher on 8/11/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "ApplicationController.h"
#import "ViewerDocument.h"
#import "ComponentManager.h"
#import "ImageLoader.h"
#import "VitaminSEEWindowController.h"
#import "EGPath.h"
#import "NSString+FileTasks.h"
#import "DesktopBackground.h"

@implementation ViewerDocument

/** Default initializer. Really calls the initWithPath: initializer with 
 * whatever the default startup path is.
 */
-(id)init
{
	return [self initWithPath:[[NSUserDefaults standardUserDefaults]
		objectForKey:@"DefaultStartupPath"]];
}

-(void)dealloc
{
	NSLog(@"Document %@ dealloccated", documentID);
	[window release];
	[viewerNotifications release];
	[super dealloc];	
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
		
		// We need a file list
		fileList = [[ComponentManager getFileListPluginNamed:@"ViewAsIcons"] build];
		NSLog(@"FILELIST: %@", fileList);
		[fileList setDelegate:self];


		window = [[VitaminSEEWindowController alloc] initWithFileList:fileList
													   document:self];
		viewerNotifications = [[NSNotificationCenter alloc] init];

		[window showWindow:window];

		[fileList setDirectory:path];
		
		// Do something to set the current path.
//		[self setDisplayedFileTo:@"/Users/elliot/Pictures/6b.jpg"];
		
		scaleRatio = 1.0f;
		scaleMode = SCALE_IMAGE_TO_FIT;
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
	NSLog(@"Receiving the path %@", path);
	if([path isDir]) 
		[fileList setDirectory:[EGPath pathWithPath:path]];
	else
		AlertSoundPlay();
}

//-----------------------------------------------------------------------------

/** 
 */
-(void)setDirectory:(EGPath*)path
{
	// Set the new path
	[fileList setDirectory:path];
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
	
	if([[file fileSystemPath] isImage]) {
		NSMutableDictionary* dic = [NSMutableDictionary 
			dictionaryWithObjectsAndKeys:
				scaleMode, @"Scale Mode",
				[NSNumber numberWithDouble:[window viewingAreaWidth]],
				@"Viewing Area Width",
				[NSNumber numberWithDouble:[window viewingAreaHeight]], 
				@"Viewing Area Height",
				HIGH_SMOOTHING, @"Smoothing",
				[NSNumber numberWithDouble:scaleRatio], @"Scale Ratio",
				currentFile, @"Path",
				self, @"Requester",
				nil];
		
//		[self startProgressIndicator];
		[ImageLoader loadTask:dic];
	}
}

//-----------------------------------------------------------------------------

/** Callback method used by the ImageLoader to actually set the image. 
 * ImageLoader is given tasks by the method setDisplayedFileTo:.
 */
-(void)receiveImage:(NSDictionary*)task
{
	// If this is still the current file (i.e., not stale...)
	if([[task objectForKey:@"Path"]  isEqual:currentFile]) {
		NSImage* image = [task objectForKey:@"Image"];
		if(image) {			
			// Set the image
			[window setImage:image];
			
			// Set the image size label
			[window setImageSizeLabelText:NSMakeSize(
				[[task objectForKey:@"Pixel Width"] floatValue],
				[[task objectForKey:@"Pixel Heigh"] floatValue])];
			
			// Set the size of the image in bytes
			[window setFileSizeLabelText:[[task objectForKey:@"Data Size"] 
				intValue]];	
		}
	}

	[task release];
	
	[self stopProgressIndicator];
}

//-----------------------------------------------------------------------------
 
/** Returns the current file being displayed.
 */
-(EGPath*)currentFile
{
	return currentFile;
}

//----------------------------------------------------------------------------- 

-(void)startProgressIndicator
{
	// Pass this message on to the Window
//	[window startProgressIndicator];
}

//-----------------------------------------------------------------------------
 
-(void)stopProgressIndicator
{
//	[window stopProgressIndicator];
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
		
	return enable;
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
}

-(BOOL)validateAction:(SEL)action
{
	// Default behaviour: only enable if we respond to this selector.
    BOOL enable = [self respondsToSelector:action];
	
	// Disable menu items when they would put the image in the state it's 
	// already currently in.
	if(action == @selector(actualSize:))
		enable = scaleMode != SCALE_IMAGE_PROPORTIONALLY || scaleRatio != 1;
	else if(action == @selector(zoomToFit:))
		enable = scaleMode != SCALE_IMAGE_TO_FIT;
//	else if(action == @selector(zoomIn:) ||
//			action == @selector(zoomOut:))
//		enable = isimage
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

// INSERT REFRESH CODE HERE...

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
