/////////////////////////////////////////////////////////////////////////
// File:          $Name$
// Module:        Window object for a viewer window.
// Part of:       VitaminSEE
//
// ID:            $Id: ApplicationController.m 123 2005-04-18 00:21:02Z elliot $
// Revision:      $Revision: 248 $
// Last edited:   $Date: 2005-07-13 20:26:59 -0500 (Wed, 13 Jul 2005) $
// Author:        $Author: elliot $
// Copyright:     (c) 2005 Elliot Glaysher
// Created:       7/31/05
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

#import "VitaminSEEWindowController.h"
#import "ViewerDocument.h"
#import "RBSplitView.h"
#import "SBCenteringClipView.h"
#import "ToolbarDelegate.h"
#import "ComponentManager.h"
#import "AppKitAdditions.h"
#import "ImageLoader.h"
#import "ApplicationController.h"

#import <Carbon/Carbon.h>

@implementation VitaminSEEWindowController

-(id)initWithFileList:(id<FileList>)inFileList 
{
	if(self = [super initWithWindowNibName:@"VitaminSEEWindow"]) {
		// Set the file list. Note that we aren't *really* setting the file list;
		// that's done by -setFileList:, which also sets the view. We set this 
		// variable here, since we can't -setFileList: until after the window has
		// been loaded, so have -awakeFromNib actually -setFileList:.
		fileList = inFileList;

		currentlyAnimated = false;
	}
	
	return self;
}

-(void)dealloc
{
	[NSObject cancelPreviousPerformRequestsWithTarget:self];
	[currentFileViewHolder setSubview:0];	
	[super dealloc];
}

-(void)awakeFromNib
{
	// Build the toolbar
	[[self window] setToolbar:[ToolbarDelegate buildToolbar]];
	
	// Set the fileList for real.
	[self setFileList:fileList];
	
	[scrollView setAutohidesScrollers:YES];
	
	// Set up the scroll view on the right
	id docView = [[scrollView documentView] retain];
	id newClipView = [[SBCenteringClipView alloc] initWithFrame:[[scrollView 
		contentView] frame]];
	[newClipView setBackgroundColor:[NSColor windowBackgroundColor]];
	[newClipView setScrollView:scrollView];
	[scrollView setContentView:(NSClipView*)newClipView];
	[newClipView release];
	[scrollView setDocumentView:docView];
	[docView release];
	
	// Set the scroll view to accept input
	[scrollView setFocusRingType:NSFocusRingAbove];
	
	// Set up our split view. We do this because the pallete is broken...
	[splitView setDelegate:self];
	RBSplitSubview* leftView = [splitView subviewAtPosition:0];
	[leftView setCanCollapse:YES];
	[leftView setMinDimension:92 andMaxDimension:0];
	RBSplitSubview* rightView = [splitView subviewAtPosition:1];
	[rightView setCanCollapse:NO];
	[rightView setMinDimension:0 andMaxDimension:0];	
	
//	SetSystemUIMode(kUIModeAllHidden, kUIOptionAutoShowMenuBar); // to enter fullscreen
}

/// Set the file list 
-(void)setFileList:(id<FileList>)newList
{
	fileList = newList;
	
	id fileListView = [fileList getView];
	[currentFileViewHolder setSubview:fileListView];
}

//////////////////////////////////////////////////////// SUBVIEW DELEGATE STUFF

-(void)didAdjustSubviews:(id)rbview
{
	[[self document] redraw];
}

//-----------------------------------------------------------------------------

- (void)splitView:(RBSplitView*)sender didCollapse:(RBSplitSubview*)subview
{
//	NSLog(@"didCollapse:");
	[[self document] redraw];
	
	// When we collapse, give the image viewer focus
	[[self window] makeFirstResponder:imageViewer];
}

//-----------------------------------------------------------------------------

- (void)splitView:(RBSplitView*)sender didExpand:(RBSplitSubview*)subview 
{
	// When we expand, make the file view first responder
	[[self document] redraw];
}

//-----------------------------------------------------------------------------

- (void)splitView:(RBSplitView*)sender wasResizedFrom:(float)oldDimension 
			   to:(float)newDimension
{
	[[self document] redraw];
}

//-----------------------------------------------------------------------------

-(void)beginCountdownToDisplayProgressIndicator
{
	[NSObject cancelPreviousPerformRequestsWithTarget:self
											 selector:@selector(startProgressIndicator)
											   object:nil];
	[self performSelector:@selector(startProgressIndicator)
			   withObject:nil
			   afterDelay:0.10];
}

//-----------------------------------------------------------------------------

-(void)cancelCountdown
{
	[NSObject cancelPreviousPerformRequestsWithTarget:self
											 selector:@selector(startProgressIndicator)
											   object:nil];		
}

//-----------------------------------------------------------------------------

// Progress indicator control
-(void)startProgressIndicator
{
	if(!currentlyAnimated)
	{
		[progressIndicator startAnimation:self];		
		currentlyAnimated = true;
	}
}

//-----------------------------------------------------------------------------

-(void)stopProgressIndicator
{
	[self cancelCountdown];
	
	if(currentlyAnimated) 
	{
		[progressIndicator stopAnimation:self];
		currentlyAnimated = false;
	}
}

//-----------------------------------------------------------------------------

-(void)setStatusText:(NSString*)statusText
{
	if(statusText)
	{
		[progressCurrentTask setStringValue:statusText];		
		[progressCurrentTask setHidden:NO];
	}
	else
		[progressCurrentTask setHidden:YES];
	
	[scrollView setNeedsDisplay:YES];
}

//-----------------------------------------------------------------------------

-(void)setImage:(NSImage*)image
{
	[imageViewer setImage:image];
}

//-----------------------------------------------------------------------------

-(void)setFileSizeLabelText:(int)fileSize
{
	if(fileSize == -1)
		[fileSizeLabel setObjectValue:@"---"];
	else
		[fileSizeLabel setObjectValue:[NSNumber numberWithInt:fileSize]];
}

//-----------------------------------------------------------------------------

-(void)setImageSizeLabelText:(NSSize)size
{
	// Truncate the size in pixels for display
	int width = size.width;
	int height = size.height;
	
	if(width == 0 && height == 0)
		[imageSizeLabel setStringValue:@"---"];
	else
		[imageSizeLabel setStringValue:[NSString stringWithFormat:@"%i x %i", 
			width, height]];
}

//-----------------------------------------------------------------------------

-(void)updateWindowTitle
{
	// pass the responsibility to the fileilst, who will also mess with the
	// proxy icon
	[fileList setWindowTitle:[self window]];
}
	
//-----------------------------------------------------------------------------

-(double)viewingAreaWidth
{
	return [NSScrollView contentSizeForFrameSize:[scrollView frame].size
						   hasHorizontalScroller:NO
							 hasVerticalScroller:NO
									  borderType:[scrollView borderType]].width;
}

//-----------------------------------------------------------------------------

-(double)viewingAreaHeight
{
	return [NSScrollView contentSizeForFrameSize:[scrollView frame].size
						   hasHorizontalScroller:NO
							 hasVerticalScroller:NO
									  borderType:[scrollView borderType]].height;
}

// We only hack around the document architecture to get some of its features.
// Therefore we need to deallocate our ViewerDocument object.
-(void)windowWillClose:(NSNotification *)aNotification
{
//	NSLog(@"Window closed!");
	id document = [self document];
	[self setDocument:nil];
	[document release];
}

- (void)windowDidResize:(NSNotification *)aNotification
{
	if(oldFileListSize != 0) 
	{
		[[splitView subviewAtPosition:0] setDimension:oldFileListSize];
		oldFileListSize = 0;
	}
	
	// Get in queue for the full redraw
	[[self document] redraw];
}

- (NSSize)windowWillResize:(NSWindow *)sender toSize:(NSSize)proposedFrameSize
{
	oldFileListSize = NSWidth([[splitView subviewAtPosition:0] frame]);
	return proposedFrameSize;
}

//-----------------------------------------------------------------------------

/**
 */
-(NSRect)windowWillUseStandardFrame:(NSWindow *)sender
					   defaultFrame:(NSRect)defaultFrame
{
	oldFileListSize = NSWidth([[splitView subviewAtPosition:0] frame]);
//	NSLog(@"Old file list size -- is %f", oldFileListSize);
//	NSLog(@"--- begin -windowWillUseStandardFrame:defaultFrame:");
	float pixelWidth = [[self document] pixelWidth];
	float pixelHeight = [[self document] pixelHeight];
	
	float nonImageWidth = [self nonImageWidth];
	float newWidth = nonImageWidth + pixelWidth;
	
	float nonImageHeight = [self nonImageHeight];
	float newHeight = nonImageHeight + pixelHeight;
	
	// If the image won't fit even in the maximized window, then calculate which
	// side is too large, and shrink it based on that if we are in scaled image
	// mode
	if(([[[self document] scaleMode] isEqual:SCALE_IMAGE_TO_FIT]) &&
	   (newHeight > NSHeight(defaultFrame) ||
		newWidth > NSWidth(defaultFrame)))
	{
		NSRect defaultContentFrame = 
			[NSWindow contentRectForFrameRect:defaultFrame
									styleMask:[[self window] styleMask]];
		
		float defaultImageWidth = NSWidth(defaultContentFrame) - nonImageWidth;
		float defaultImageHeight = NSHeight(defaultContentFrame) - nonImageHeight;

		float ratio = MIN(defaultImageWidth / pixelWidth,
						  defaultImageHeight / pixelHeight);
		
		newWidth = nonImageWidth + (pixelWidth * ratio);
		newHeight = nonImageHeight + (pixelHeight * ratio);
	}
	else {
		// We aren't in a scaling mode. That means we have to make sure that the
		// scroll bars aren't a menace, displaying both when only one is needed
		// because we didn't compensate for it.
		if(newHeight > NSHeight(defaultFrame))
			newWidth += NSWidth([[scrollView horizontalScroller] frame]);
		if(newWidth > NSWidth(defaultFrame))
			newHeight += NSHeight([[scrollView horizontalScroller] frame]);
	}
	
//	NSLog(@"new: %@ defaultSize: %@", 
//		  NSStringFromSize(NSMakeSize(newWidth,newHeight)),
//		  NSStringFromSize(defaultFrame.size));
	
	// Code taken from a very nice Mac Dev Center article on window zooming:
	// http://www.macdevcenter.com/pub/a/mac/2002/05/16/cocoa.html?page=2
	// Hint to Apple: Incorporate that into an official tutorial! That's
	// exactly what's needed to explain this!
	float stdX, stdY, stdW, stdH, defX, defY, defW, defH;    
    NSRect stdFrame = [NSWindow contentRectForFrameRect:[sender frame] 
											  styleMask:[sender styleMask]];
	
    stdFrame.origin.y += stdFrame.size.height;
    stdFrame.origin.y -= newHeight;
    stdFrame.size.height = newHeight;
    stdFrame.size.width = newWidth;
    
    stdFrame = [NSWindow frameRectForContentRect:stdFrame 
									   styleMask:[sender styleMask]];
    
    stdX = stdFrame.origin.x;
    stdY = stdFrame.origin.y;
    stdW = stdFrame.size.width;
    stdH = stdFrame.size.height;
    
    defX = defaultFrame.origin.x;
    defY = defaultFrame.origin.y;
    defW = defaultFrame.size.width;
    defH = defaultFrame.size.height;
    
    if ( stdH > defH ) {
		stdFrame.size.height = defH;
		stdFrame.origin.y = defY;
    } else if ( stdY < defY ) {
		stdFrame.origin.y = defY;
    }
    
    if ( stdW > defW ) {
		stdFrame.size.width = defW;
		stdFrame.origin.x = defX;
    } else if ( stdX < defX ) {
		stdFrame.origin.x = defX;
    } 
	
	return stdFrame;
}

- (void)windowDidBecomeMain:(NSNotification *)aNotification
{
//	NSLog(@"Became main!");
	// Notify the Application controller that this window has become main,
	// and that it's 
	[[ApplicationController controller] becomeMainDocument:[self document]];
}

-(void)windowDidResignMain:(NSNotification *)aNotification
{
//	NSLog(@"Lost main!");
	// Notify the Application controller that it should check to see if there
	// are any windows left.
	[[ApplicationController controller] resignMainDocument:[self document]];
}

//windowWillReturnUndoManager:

-(float)nonImageWidth
{
	// Get the subtract the scrollView's frame width from the 
	NSRect content = [NSWindow contentRectForFrameRect:[[self window] frame] 
											 styleMask:[[self window] styleMask]];
	
	
	return content.size.width - [scrollView frame].size.width;
}

/** The size of the window's content view that isn't taken up by the scrollView.
 * We can't just subtract the scrollView's contentView's frame size from the
 * window's content rect because we call this method while we're resizing said
 * content view!
 */
-(float)nonImageHeight
{
	NSRect content = [NSWindow contentRectForFrameRect:[[self window] frame] 
											 styleMask:[[self window] styleMask]];
	
	return content.size.height - [scrollView frame].size.height;
}

-(BOOL)fileListHidden
{
	return [[splitView subviewAtPosition:0] isCollapsed];
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
		if([self fileListHidden])
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
	RBSplitSubview* firstSplit = [splitView subviewAtPosition:0];
	if ([firstSplit isCollapsed]) 
		[firstSplit expandWithAnimation:NO withResize:NO];
	else 
		[firstSplit collapseWithAnimation:NO withResize:NO];
}

-(void)setFileListVisible:(BOOL)visible
{
	RBSplitSubview* firstSplit = [splitView subviewAtPosition:0];

	if(visible && [firstSplit isCollapsed])
		[firstSplit expandWithAnimation:NO withResize:NO];
	else if(!visible && ![firstSplit isCollapsed])
		[firstSplit collapseWithAnimation:NO withResize:NO];
}

@end
