//
//  VitaminSEEWindowController.m
//  VitaminSEE
//
//  Created by Elliot Glaysher on 7/31/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "VitaminSEEWindowController.h"
#import "ViewerDocument.h"
#import "RBSplitView.h"
#import "SBCenteringClipView.h"
#import "ToolbarDelegate.h"
#import "ComponentManager.h"
#import "AppKitAdditions.h"

@implementation VitaminSEEWindowController

-(id)initWithFileList:(id<FileList>)inFileList 
			 document:(ViewerDocument*)viewerDocument
{
	if(self = [super initWithWindowNibName:@"VitaminSEEWindow"]) {
		// Set the file list. Note that we aren't *really* setting the file list;
		// that's done by -setFileList:, which also sets the view. We set this 
		// variable here, since we can't -setFileList: until after the window has
		// been loaded, so have -awakeFromNib actually -setFileList:.
		fileList = inFileList;
		
		[self setDocument:viewerDocument];
		[[self window] setToolbar:[ToolbarDelegate buildToolbar]];
	}
	
	return self;
}

-(void)dealloc
{
	[super dealloc];
}

-(void)awakeFromNib
{
	// Set the fileList for real.
	[self setFileList:fileList];
	
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
//	[splitView setDelegate:self];
	RBSplitSubview* leftView = [splitView subviewAtPosition:0];
	[leftView setCanCollapse:YES];
	[leftView setMinDimension:92 andMaxDimension:0];
	RBSplitSubview* rightView = [splitView subviewAtPosition:1];
	[rightView setCanCollapse:NO];
	[rightView setMinDimension:0 andMaxDimension:0];	
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
//	[pictureState redraw];
}

- (void)splitView:(RBSplitView*)sender didCollapse:(RBSplitSubview*)subview
{
	// When we collapse, give the image viewer focus
	[scrollView setNextKeyView:nil];
//	[self selectFirstResponder];
	[imageViewer setNextKeyView:imageViewer];
}

- (void)splitView:(RBSplitView*)sender didExpand:(RBSplitSubview*)subview 
{
	// When we expand, make the file view first responder
//	[self selectFirstResponder];
//	[viewAsIconsController connectKeyFocus:scrollView];
//	[mainVitaminSeeWindow setViewsNeedDisplay:YES];
}

- (void)splitView:(RBSplitView*)sender wasResizedFrom:(float)oldDimension 
			   to:(float)newDimension
{
//	[mainVitaminSeeWindow setViewsNeedDisplay:YES];
}

// Redraw the window when the seperator between the file list and image view
// is moved.
-(void)splitViewDidResizeSubviews:(NSNotification*)notification
{
//	[viewAsIconsController clearCache];
//	[self redraw];
}

// Progress indicator control
-(void)startProgressIndicator
{
	[scrollView setNeedsDisplay:YES];
	[progressIndicator setHidden:NO];
	[progressIndicator startAnimation:self];
}

-(void)stopProgressIndicator
{
	[scrollView setNeedsDisplay:YES];
	[progressIndicator stopAnimation:self];
	[progressIndicator setHidden:YES];
}

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

-(void)setImage:(NSImage*)image
{
	[imageViewer setAnimates:YES];
	[imageViewer setImage:image];
	[imageViewer setFrameSize:[image size]];
	
	// Set the correct cursor. If the picture is larger then the viewing area,
	// we use a grabing cursor. Otherwise, we use the standard pointer.
	NSSize imageSize = [image size];
	NSSize scrollViewSize = [scrollView contentSize];
	if(imageSize.width > scrollViewSize.width ||
	   imageSize.height > scrollViewSize.height)
	{
		if(!handCursor)
			handCursor = [[NSCursor alloc] initWithImage:[NSImage 
				imageNamed:@"hand_open"] hotSpot:NSMakePoint(8, 8)];
		[(NSScrollView*)[imageViewer superview] setDocumentCursor:handCursor];
	}
	else
		[(NSScrollView*)[imageViewer superview] setDocumentCursor:nil];
}

-(void)setFileSizeLabelText:(int)fileSize
{
	if(fileSize == -1)
		[fileSizeLabel setObjectValue:@"---"];
	else
		[fileSizeLabel setObjectValue:[NSNumber numberWithInt:fileSize]];
}

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

//-(IBAction)setImageAsDesktop:(id)sender
//{
//	if([currentImageFile isImage])
//		[[self desktopBackgroundController] setDesktopBackgroundToFile:currentImageFile];
//	else if([currentImageFile isDir])
//		[[self desktopBackgroundController] setDesktopBackgroundToFolder:currentImageFile];
//}

-(double)viewingAreaWidth
{
	return [scrollView contentSize].width;
}

-(double)viewingAreaHeight
{
	return [scrollView contentSize].height;
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
		if([[splitView subviewAtPosition:0] isCollapsed])
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

@end
