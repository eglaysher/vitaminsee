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
#import "FullScreenControlWindowController.h"

#import <Carbon/Carbon.h>

@implementation FullscreenWindowController

+(void)initialize
{
	// Note fullscreen default preferences
	NSMutableDictionary *defaultPrefs = [NSMutableDictionary dictionary];
	[defaultPrefs setObject:[NSNumber numberWithBool:YES] forKey:@"FullscreenDisplayFileList"];
	[defaultPrefs setObject:[NSNumber numberWithBool:YES] forKey:@"FullscreenDisplayControls"];

	[[NSUserDefaults standardUserDefaults] registerDefaults: defaultPrefs];
}

// ---------------------------------------------------------------------------

-(id)init
{
	if(self = [super initWithWindowNibName:@"ImageViewing"]) {
		// Load the FileList
		fileListViewerController = [[FileListWindowController alloc] init];
		[fileListViewerController window];
		
		// Load the Controls
		fullScreenControlWindowController = 
			[[FullScreenControlWindowController alloc] init];
		[fullScreenControlWindowController window];
		
		// Register to receive a notification for when we're about to quit.
		// We need to do this because we need to note the windows display
		// status, and save it
		[[NSNotificationCenter defaultCenter] 
			addObserver:self
			   selector:@selector(applicationWillTerminate:)
				   name:NSApplicationWillTerminateNotification
				 object:nil];
		shouldRecordWindowState = YES;
	}
	
	return self;
}

// ---------------------------------------------------------------------------

-(void)dealloc
{
	[fileListViewerController release];
	[fullScreenControlWindowController release];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];

	[super dealloc];
}

// ---------------------------------------------------------------------------

- (void)applicationWillTerminate:(NSNotification *)aNotification
{
	[self recordWindowStates];
	shouldRecordWindowState = NO;
}

// ---------------------------------------------------------------------------

-(void)windowWillClose:(id)huh
{
	// Record the windows' states if we aren't immediatly closing down the 
	// application
	if(shouldRecordWindowState)
	{
		[self recordWindowStates];
	}
	
	// Now close the windows
	[fileListViewerController close];
	[fullScreenControlWindowController close];
	
	// Restore the menu bar to the way it was before fullscreen mode.
	SetSystemUIMode(kUIModeNormal, 0); 
}

// ---------------------------------------------------------------------------

-(void)recordWindowStates
{
	// Record the current state of the windows.
	NSUserDefaults* ud = [NSUserDefaults standardUserDefaults];
	BOOL visible = [[fileListViewerController window] isVisible];
	[ud setObject:[NSNumber numberWithBool:visible]
		   forKey:@"FullscreenDisplayFileList"];
	
	visible = [[fullScreenControlWindowController window] isVisible];
	[ud setObject:[NSNumber numberWithBool:visible]
		   forKey:@"FullscreenDisplayControls"];	
}

// ---------------------------------------------------------------------------

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

// ---------------------------------------------------------------------------

-(void)becomeFullscreen
{
	// Capture the screen for fullscreen:
	NSWindow* fullscreenWindow = [self window];
	
	[fullscreenWindow setFrame:[[NSScreen mainScreen] frame] display:YES];
	[fullscreenWindow makeKeyAndOrderFront:self];
	
	// Hide everything, but allow the menu bar to slide down.
	SetSystemUIMode(kUIModeAllHidden, kUIOptionAutoShowMenuBar); 
	
	// Now lets check if we should display the file list and the fullscreen
	// controls
	NSUserDefaults* ud = [NSUserDefaults standardUserDefaults];
	if([[ud objectForKey:@"FullscreenDisplayFileList"] boolValue])
		[fileListViewerController showWindow:self];
	if([[ud objectForKey:@"FullscreenDisplayControls"] boolValue])
		[fullScreenControlWindowController showWindow:self];
}

// ---------------------------------------------------------------------------

/// Set the file list 
-(void)setFileList:(id<FileList>)newList
{
	// Pass this message off to the FileListWindowController
	[fileListViewerController setFileList:newList];
}

//-----------------------------------------------------------------------------

// The following functions exist soley so that exceptions aren't raised at 
// runtime about their non-existance. They all deal with functionality that's
// stripped out in full screen mode.
-(void)setStatusText:(NSString*)statusText {}
-(void)updateWindowTitle {}


// These functions get forwarded to the file list window

-(void)beginCountdownToDisplayProgressIndicator
{
	[fileListViewerController beginCountdownToDisplayProgressIndicator];
}

-(void)cancelCountdown
{
	[fileListViewerController cancelCountdown];
}

-(void)startProgressIndicator
{
	[fileListViewerController startProgressIndicator];
}

-(void)stopProgressIndicator
{
	[fileListViewerController stopProgressIndicator];
}

//-----------------------------------------------------------------------------

-(void)setFileSizeLabelText:(int)fileSize 
{
	[fileListViewerController setFileSizeLabelText:fileSize];
}

// ---------------------------------------------------------------------------

-(void)setImageSizeLabelText:(NSSize)size 
{
	[fileListViewerController setImageSizeLabelText:size];
}

//-----------------------------------------------------------------------------

-(void)setImage:(NSImage*)image
{
	[imageViewer setImage:image];
}

// ---------------------------------------------------------------------------

-(double)viewingAreaWidth
{
	return [NSScrollView contentSizeForFrameSize:[scrollView frame].size
						   hasHorizontalScroller:NO
							 hasVerticalScroller:NO
									  borderType:[scrollView borderType]].width;
}

// ---------------------------------------------------------------------------

-(double)viewingAreaHeight
{
	return [NSScrollView contentSizeForFrameSize:[scrollView frame].size
						   hasHorizontalScroller:NO
							 hasVerticalScroller:NO
									  borderType:[scrollView borderType]].height;
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
	else if(action == @selector(toggleFullScreenControls:))
	{
		if(![[fullScreenControlWindowController window] isVisible])
			[anItem setTitle:NSLocalizedString(@"Show Fullscreen Controls", 
											   @"Text in View menu")];
		else
			[anItem setTitle:NSLocalizedString(@"Hide Fullscreen Controls",
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

//-----------------------------------------------------------------------------

/**
 */
-(void)toggleFullScreenControls:(id)sender
{
	if(![[fullScreenControlWindowController window] isVisible])
		[fullScreenControlWindowController showWindow:self];
	else
		[[fullScreenControlWindowController window] performClose:self];	
}

@end
