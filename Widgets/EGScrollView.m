/////////////////////////////////////////////////////////////////////////
// File:          $URL$
// Module:        Scroll View that can become key, processes key input as
//                scrolling, and draws a focus ring.
// Part of:       VitaminSEE
//
// Revision:      $Revision$
// Last edited:   $Date$
// Author:        $Author$
// Copyright:     (c) 2005 Elliot Glaysher
// Created:       5/11/05
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

-(void)keyDown:(NSEvent*)theEvent 
{
	NSRect clipRect = [[self contentView] bounds];
	NSSize documentSize = [[self documentView] frame].size;
	
	if([theEvent keyCode] == ARROW_LEFT_KEY)
	{
		[self scrollTheViewByX:-([self horizontalLineScroll]) y:0];		
	}
	else if([theEvent keyCode] == ARROW_RIGHT_KEY)
	{
		[self scrollTheViewByX:[self horizontalLineScroll] y:0];		
	}
	else if([theEvent keyCode] == ARROW_UP_KEY)
	{
		// If we are at the very top of the document, then 
		if(clipRect.origin.y + clipRect.size.height + 0.5 >= documentSize.height)
			NSLog(@"Flipping!");
		else
		{
			// Otherwise, scroll the picture up			
			[self scrollTheViewByX:0 y:[self verticalLineScroll]];					
		}
	}
	else if([theEvent keyCode] == ARROW_DOWN_KEY)
	{
		if(clipRect.origin.y <= 0.9)
			NSLog(@"Flipping down!");
		else
			[self scrollTheViewByX:0 y:-([self verticalLineScroll])];		
	}
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
