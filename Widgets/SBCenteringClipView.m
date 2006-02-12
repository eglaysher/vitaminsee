/////////////////////////////////////////////////////////////////////////
// File:          $Name$
// Module:        Main Controller Class
// Part of:       VitaminSEE
//
// ID:            $Id: ApplicationController.m 123 2005-04-18 00:21:02Z elliot $
// Revision:      $Revision$
// Last edited:   $Date$
// Author:        $Author$
// Copyright:     (c) 2005 Somebody Else
// Created:       2/3/05
//
/////////////////////////////////////////////////////////////////////////
//
// This class is 99% based on an article on the net. Google for SBCenteringClipView.

#import "SBCenteringClipView.h"
#import "EGScrollView.h"

@implementation SBCenteringClipView

-(void)setScrollView:(id)inScrollView
{
	scrollView = inScrollView;
}

- (void)mouseDown:(NSEvent *)theEvent
{
	[scrollView noteMouseDown];
}

// ----------------------------------------

-(void)centerDocument
{
	NSRect docRect = [[self documentView] frame];
	NSRect clipRect = [self bounds];
	
	// We can leave these values as integers (don't need the "2.0")
	if( docRect.size.width < clipRect.size.width )
		clipRect.origin.x = roundf( ( docRect.size.width - clipRect.size.width ) / 2.0 );
	
	if( docRect.size.height < clipRect.size.height )
		clipRect.origin.y = roundf( ( docRect.size.height - clipRect.size.height ) / 2.0 );
	
	// Probably the most efficient way to move the bounds origin.
	[self scrollToPoint:clipRect.origin];
	
	// We could use this instead since it allows a scroll view to coordinate scrolling between multiple clip views.
	// [[self superview] scrollClipView:self toPoint:clipRect.origin];
}

// ----------------------------------------
// We need to override this so that the superclass doesn't override our new origin point.

-(NSPoint)constrainScrollPoint:(NSPoint)proposedNewOrigin
{
	NSRect docRect = [[self documentView] frame];
	NSRect clipRect = [self bounds];
	NSPoint newScrollPoint = proposedNewOrigin;
	float maxX = docRect.size.width - clipRect.size.width;
	float maxY = docRect.size.height - clipRect.size.height;
	
	// If the clip view is wider than the doc, we can't scroll horizontally
	if( docRect.size.width < clipRect.size.width )
		newScrollPoint.x = roundf( maxX / 2.0 );
	else
		newScrollPoint.x = roundf( MAX(0,MIN(newScrollPoint.x,maxX)) );
	
	// If the clip view is taller than the doc, we can't scroll vertically
	if( docRect.size.height < clipRect.size.height )
		newScrollPoint.y = roundf( maxY / 2.0 );
	else
		newScrollPoint.y = roundf( MAX(0,MIN(newScrollPoint.y,maxY)) );
	
	return newScrollPoint;
}

// ----------------------------------------
// These two methods get called whenever the subview changes

-(void)viewBoundsChanged:(NSNotification *)notification
{
	[super viewBoundsChanged:notification];
	[self centerDocument];
}

-(void)viewFrameChanged:(NSNotification *)notification
{
	[super viewFrameChanged:notification];
	[self centerDocument];
}

// ----------------------------------------
// These superclass methods change the bounds rect directly without sending any notifications,
// so we're not sure what other work they silently do for us. As a result, we let them do their
// work and then swoop in behind to change the bounds origin ourselves. This appears to work
// just fine without us having to reinvent the methods from scratch.

- (void)setFrame:(NSRect)frameRect
{
	[super setFrame:frameRect];
	[self centerDocument];
}

- (void)setFrameOrigin:(NSPoint)newOrigin
{
	[super setFrameOrigin:newOrigin];
	[self centerDocument];
}

- (void)setFrameSize:(NSSize)newSize
{
	[super setFrameSize:newSize];
	[self centerDocument];
}

- (void)setFrameRotation:(float)angle
{
	[super setFrameRotation:angle];
	[self centerDocument];
}

@end
