/////////////////////////////////////////////////////////////////////////
// File:          $Name$
// Module:        Scroll View that can become key, processes key input as
//                scrolling, and draws a focus ring.
// Part of:       VitaminSEE
//
// Revision:      $Revision: 192 $
// Last edited:   $Date: 2005-05-18 01:07:24 -0400 (Wed, 18 May 2005) $
// Author:        $Author: glaysher $
// Copyright:     (c) 2005 Elliot Glaysher
// Created:       5/11/05
//
/////////////////////////////////////////////////////////////////////////
//
// This library is free software; you can redistribute it and/or
// modify it under the terms of the GNU Lesser General Public
// License as published by the Free Software Foundation; either
// version 2.1 of the License, or (at your option) any later version.
//  
// This library is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
// Lesser General Public License for more details.
//  
// You should have received a copy of the GNU Lesser General Public
// License along with this library; if not, write to the Free Software
// Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  
// USA
//
/////////////////////////////////////////////////////////////////////////


#import "EGScrollView.h"

#define   ARROW_UP_KEY        0x7E
#define   ARROW_DOWN_KEY      0x7D
#define   ARROW_LEFT_KEY      0x7B
#define   ARROW_RIGHT_KEY     0x7C

@implementation EGScrollView

-(void)noteMouseDown
{
	[[self window] makeFirstResponder:self];
}

// Move this to a NSScrollView subclass!?
- (BOOL)acceptsFirstResponder
{
	return YES;
}

-(BOOL)becomeFirstResponder
{
	shouldDrawFocusRing = YES;
	[self setNeedsDisplay:YES];
	return YES;
}

- (BOOL)canBecomeKeyView
{
	return YES;
}

- (BOOL)needsPanelToBecomeKey
{
	return YES;
}

-(void)keyDown:(NSEvent*)theEvent {
	if([theEvent keyCode] == ARROW_LEFT_KEY)
		[self scrollTheViewByX:-([self horizontalLineScroll]) y:0];
	else if([theEvent keyCode] == ARROW_RIGHT_KEY)
		[self scrollTheViewByX:[self horizontalLineScroll] y:0];
	else if([theEvent keyCode] == ARROW_UP_KEY)
		[self scrollTheViewByX:0 y:[self verticalLineScroll]];
	else if([theEvent keyCode] == ARROW_DOWN_KEY)
		[self scrollTheViewByX:0 y:-([self verticalLineScroll])];
	else
		[super keyDown:theEvent];
}

-(void)scrollTheViewByX:(float)x y:(float)y
{
	NSRect rect = [self documentVisibleRect];
	NSRect clipRect = [[self contentView] bounds];
	NSSize documentSize = [[self documentView] frame].size;
	
	if(documentSize.width > clipRect.size.width)
	{
		rect.origin.x += x;
		
		if(rect.origin.x < 0)
			rect.origin.x = 0;
		else if(rect.origin.x > documentSize.width - rect.size.width)
			rect.origin.x = documentSize.width - rect.size.width;
	}
	
	if(documentSize.height > clipRect.size.height)
	{
		rect.origin.y += y;
		
		if(rect.origin.y < 0)
			rect.origin.y = 0;
		else if(rect.origin.y > documentSize.height - rect.size.height)
			rect.origin.y = documentSize.height - rect.size.height;
	}

	[[self contentView] scrollToPoint:rect.origin];
	[self reflectScrolledClipView: [self contentView]];
}

- (BOOL)needsDisplay; 
{
    NSResponder *resp = nil; 
    if ([[self window] isKeyWindow]) { 
        resp = [[self window] firstResponder]; 
        if (resp == lastResp) return [super needsDisplay]; 
    } else if (lastResp == nil) { 
        return [super needsDisplay]; 
    } 
    shouldDrawFocusRing = (resp != nil && [resp isKindOfClass: [NSView class]] && 
                           [(NSView *)resp isDescendantOf: self]); // [sic] 
    lastResp = resp; 

	NSRect boundsWithSideView = [self bounds];
    [self setKeyboardFocusRingNeedsDisplayInRect:boundsWithSideView]; 
    return YES; 
} 

- (void)drawRect:(NSRect)rect {
    [super drawRect: rect]; 
    if (shouldDrawFocusRing) { 
        NSSetFocusRingStyle(NSFocusRingOnly); 
        NSRectFill(rect);
    } 
} 

@end
