//
//  FullscreenWindowController.m
//  VitaminSEE
//
//  Created by Elliot on 2/12/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "FullscreenWindowController.h"
#import "SBCenteringClipView.h"
#import "FileListWindowController.h"

#import <Carbon/Carbon.h>

@implementation FullscreenWindowController

-(id)init
{
	if(self = [super initWithWindowNibName:@"ImageViewing"]) {
	}
	
	return self;
}

-(void)dealloc
{
	[fileListViewerController release];
	[super dealloc];
}

-(void)windowWillClose:(id)huh
{
	// Close the other windows
	[fileListViewerController close];
	
	// Restore the menu bar to the way it was before fullscreen mode.
	SetSystemUIMode(kUIModeNormal, 0); 
}

-(void)awakeFromNib
{
	// Set up the main window
	NSRect screenRect = [[NSScreen mainScreen] frame];
	
	// Set up the scroll view on the right
	id docView = [[scrollView documentView] retain];
	id newClipView = [[SBCenteringClipView alloc] initWithFrame:[[scrollView 
		contentView] frame]];
	[newClipView setBackgroundColor:[NSColor blackColor]];
	[newClipView setScrollView:scrollView];
	[scrollView setContentView:(NSClipView*)newClipView];
	[newClipView release];
	[scrollView setDocumentView:docView];
	[docView release];
	
	[[self window] setFrame:screenRect display:YES];
	
	// Now set up the image view
	[scrollView setAutohidesScrollers:YES];
}

-(void)becomeFullscreen
{
	// Capture the screen for fullscreen:
	NSWindow* fullscreenWindow = [self window];
	
	[fullscreenWindow setFrame:[[NSScreen mainScreen] frame] display:YES];
	[fullscreenWindow makeKeyAndOrderFront:self];
	
	// Hide everything, but allow the menu bar to slide down.
	SetSystemUIMode(kUIModeAllHidden, kUIOptionAutoShowMenuBar); 
	
	// Now, we show the file list.
	fileListViewerController = [[FileListWindowController alloc] init];
	[fileListViewerController showWindow:self];
}

// ---------------------------------------------------------------------------

/// Set the file list 
-(void)setFileList:(id<FileList>)newList
{
	// Pass this message off to the FileListWindowController
	[fileListViewerController setFileList:newList];
	
//	fileList = newList;
//	
//	id fileListView = [fileList getView];
//	[currentFileViewHolder setSubview:fileListView];
}

//-----------------------------------------------------------------------------

// The following functions exist soley so that exceptions aren't raised at 
// runtime about their non-existance. They all deal with functionality that's
// stripped out in full screen mode.

-(void)beginCountdownToDisplayProgressIndicator {}
-(void)cancelCountdown {}
-(void)setStatusText:(NSString*)statusText {}
-(void)updateWindowTitle {}
-(void)startProgressIndicator {}
-(void)stopProgressIndicator {}

// These need to be set eventually.
-(void)setFileSizeLabelText:(int)fileSize 
{
	[fileListViewerController setFileSizeLabelText:fileSize];
}

-(void)setImageSizeLabelText:(NSSize)size 
{
	[fileListViewerController setImageSizeLabelText:size];
}

//-----------------------------------------------------------------------------

-(void)setImage:(NSImage*)image
{
	[imageViewer setImage:image];
}

-(double)viewingAreaWidth
{
	double width = [NSScrollView contentSizeForFrameSize:[scrollView frame].size
						   hasHorizontalScroller:NO
							 hasVerticalScroller:NO
									  borderType:[scrollView borderType]].width;
	return width;
}

-(double)viewingAreaHeight
{
	double height = [NSScrollView contentSizeForFrameSize:[scrollView frame].size
						   hasHorizontalScroller:NO
							 hasVerticalScroller:NO
									  borderType:[scrollView borderType]].height;
	return height;
}

//-----------------------------------------------------------------------------

/** Menu item validation
*/
-(BOOL)validateMenuItem:(NSMenuItem *)anItem
{
	// Default behaviour: only enable if we respond to this selector.
	SEL action = [anItem action];
    BOOL enable = [self respondsToSelector:action];
	
	if(action == @selector(toggleFileList:))
	{
		// In case of toggleFileList:, we need to make sure that we present the
		// correct label to the user.
		if(![[fileListViewerController window] isVisible])
			[anItem setTitle:NSLocalizedString(@"Show File List", 
											   @"Text in View menu")];
		else
			[anItem setTitle:NSLocalizedString(@"Hide File List",
											   @"Text in View menu")];		
	}
	
	return enable;
}

//-----------------------------------------------------------------------------
// VIEW MENU
//-----------------------------------------------------------------------------

/** Expands or collapses the file list in this window.
*/
-(void)toggleFileList:(id)sender
{
	if(![[fileListViewerController window] isVisible])
		[fileListViewerController showWindow:self];
	else
		[[fileListViewerController window] performClose:self];
}

@end
