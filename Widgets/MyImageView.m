/////////////////////////////////////////////////////////////////////////
// File:          $Name$
// Module:        MyImageView: Implements hand grab scrolling
// Part of:       VitaminSEE
//
// Revision:      $Revision$
// Last edited:   $Date$
// Copyright:     Matt Gemmell (I'm guessing here; there's no explicit
//                attribution, but it comes from his source repository:
//                http://www.scotlandsoftware.com/products/source/
//
/////////////////////////////////////////////////////////////////////////
//
// My modifications: Each function first checks to see if the contained image
// is larger then the size of its container. If it's smaller or equal, then
// behave normally. Otherwise, do what this code orriginally did: show the hand
// cursor and allow dragging.
//
// 5/10/05: Adding code to make the image viewer accept key

#import "MyImageView.h"
#import "EGScrollView.h"

@implementation MyImageView

- (void)mouseDown:(NSEvent *)theEvent
{
	[scrollView noteMouseDown];
	
	NSSize imageSize = [[self image] size];
	NSSize contentSize = [(NSScrollView*)[[self superview] superview] contentSize];
	if(imageSize.height > contentSize.height || imageSize.width > contentSize.width)
	{
		startPt = [theEvent locationInWindow];
		startOrigin = [(NSClipView*)[self superview] documentVisibleRect].origin;

		NSCursor *grabCursor = [NSCursor closedHandCursor];
		
		[scrollView setDocumentCursor:grabCursor];
	}
	else
		[scrollView setDocumentCursor:nil];
}

- (void)mouseDragged:(NSEvent *)theEvent
{
	NSSize imageSize = [[self image] size];
	NSSize contentSize = [(NSScrollView*)[[self superview] superview] contentSize];
	if(imageSize.height > contentSize.height || imageSize.width > contentSize.width)
	{
		[self scrollPoint:
			NSMakePoint(startOrigin.x - ([theEvent locationInWindow].x - startPt.x),
						startOrigin.y - ([theEvent locationInWindow].y - startPt.y))];
	}
}

- (void)mouseUp:(NSEvent *)theEvent
{	
	NSSize imageSize = [[self image] size];
	NSSize contentSize = [(NSScrollView*)[[self superview] superview] contentSize];
	if(imageSize.height > contentSize.height || imageSize.width > contentSize.width)
	{
		NSCursor *handCursor = [NSCursor openHandCursor];
		[(NSScrollView*)[self superview] setDocumentCursor:handCursor];
	}
	else
		[(NSScrollView*)[self superview] setDocumentCursor:nil];
}

@end
