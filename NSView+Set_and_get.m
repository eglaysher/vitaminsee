/*
	NSView: Set and get a view's single subview
	Original Source: <http://cocoa.karelia.com/AppKit_Categories/NSView__Set_and_get.m>
	(See copyright notice at <http://cocoa.karelia.com>)
*/

//COPYRIGHT AND PERMISSION NOTICE
//
//Copyright © 2003 Karelia Software, LLC. All rights reserved.
//
//Permission to use, copy, modify, and distribute this software for any purpose 
//with or without fee is hereby granted, provided that the above copyright
//notice and this permission notice appear in all copies.
//
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
//IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
//FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT OF THIRD PARTY RIGHTS.
//IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, 
//DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR 
//OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE
//OR OTHER DEALINGS IN THE SOFTWARE.
//
//Except as contained in this notice, the name of a copyright holder shall not 
//be used in advertising or otherwise to promote the sale, use or other dealings
//in this Software without prior written authorization of the copyright holder.

@implementation NSView (Set_and_get)

/*"	Set inView to be the subview of self.  If there is currently no subview, it is impossible to properly size the subview to fit within the subview.
"*/

- (void) setSubview:(NSView *)inView
{
	NSArray *subviews = [self subviews];
	
	// Replace or insert subview if not the right one already
	if (0 == [subviews count])
	{
		NSLog(@"Adding single subview");
		[self addSubview:inView];		// ANY WAY TO AUTO-RESIZE IT?
	}
	else if ([subviews objectAtIndex:0] != inView)
	{
		NSView *oldSubview = [subviews objectAtIndex:0];
		NSRect frame = [oldSubview frame];
		NSLog(@"frame.origin.[%f, %f] frame.size.[%f, %f] ", frame.origin.x, frame.origin.y,
			  frame.size.width, frame.size.height);
		frame.origin.x = frame.origin.y = 0;
		frame.size.width -= 6;
		frame.size.height -= 6;
		[oldSubview removeFromSuperview];
		[inView setFrame:frame];
		[self addSubview:inView];
	}
}

/*"	Return the single (or first) subview of self.
"*/
- (id) subview
{
	NSLog(@"Getting subview...");
	id result = nil;
	NSArray *subviews = [self subviews];
	if ([subviews count])
	{
		result = [subviews objectAtIndex:0];
	}
	return result;
}

@end