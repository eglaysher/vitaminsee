//
//  FullscreenWindowController.m
//  VitaminSEE
//
//  Created by Elliot on 2/12/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "FullscreenWindowController.h"
#import "SBCenteringClipView.h"

#import <Carbon/Carbon.h>

@implementation FullscreenWindowController

-(id)init
{
	if(self = [super initWithWindowNibName:@"ImageViewing"]) {
		NSLog(@"Nib succedded!");
//		[self window];
	}
	
	return self;
}

-(void)dealloc
{
	NSLog(@"Closing fullscreen window.");
	[[self window] close];
	SetSystemUIMode(kUIModeNormal, kUIOptionAutoShowMenuBar); // to enter fullscreen	
	[super dealloc];
}

-(void)awakeFromNib
{
	// Set up the main window
	NSRect screenRect = [[NSScreen mainScreen] frame];
	
	NSLog(@"Screen size: %@", NSStringFromRect(screenRect));
	
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
	
	[self setWindow:[[NSWindow alloc] initWithContentRect:screenRect
												styleMask:NSBorderlessWindowMask
												  backing:NSBackingStoreBuffered
													defer:NO
												   screen:[NSScreen mainScreen]]];
	
	// Now fish out the content view from the panel in the NIB.
	[viewerPanel setFrame:screenRect display:YES];
	[[self window] setContentView:[viewerPanel contentView]];
	
	// Now set up the image view
	[scrollView setAutohidesScrollers:YES];
}

-(void)becomeFullscreen
{
	// Capture the screen for fullscreen:
	NSWindow* fullscreenWindow = [self window];
	NSLog(@"Window: %@", fullscreenWindow);
	
	[fullscreenWindow setFrame:[[NSScreen mainScreen] frame] display:YES];
	[fullscreenWindow makeKeyAndOrderFront:self];
	
	SetSystemUIMode(kUIModeAllHidden, kUIOptionAutoShowMenuBar); // to enter fullscreen	
}

// ---------------------------------------------------------------------------

/// Set the file list 
-(void)setFileList:(id<FileList>)newList
{
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
-(void)setFileSizeLabelText:(int)fileSize {}
-(void)setImageSizeLabelText:(NSSize)size {}

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
	NSLog(@"Width: %f", width);
	return width;
}

-(double)viewingAreaHeight
{
	NSLog(@"ScrollView frame: %@", NSStringFromRect([scrollView frame]));
	double height = [NSScrollView contentSizeForFrameSize:[scrollView frame].size
						   hasHorizontalScroller:NO
							 hasVerticalScroller:NO
									  borderType:[scrollView borderType]].height;
	NSLog(@"Height: %f", height);
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
//		if([[splitView subviewAtPosition:0] isCollapsed])
//			[anItem setTitle:NSLocalizedString(@"Show File List", 
//											   @"Text in View menu")];
//		else
//			[anItem setTitle:NSLocalizedString(@"Hide File List",
//											   @"Text in View menu")];		
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
	// The semantics here change quite a lot. Fix this.
}

@end
