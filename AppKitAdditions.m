//
//  AppKitAdditions.m
//  VitaminSEE
//
//  Created by Elliot on 3/23/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//
// This file is filled with other people's code so their copyright notices are
// included with their code.

#import "AppKitAdditions.h"

// -----------------------------------------------------------------------------

//  NSGrowlAdditions.m
//  Growl
//
//  Created by Karl Adam on Fri May 28 2004.
//  Copyright 2004 The Growl Project. All rights reserved.
//
// This file is under the BSD License, refer to License.txt for details
@implementation NSWorkspace (GrowlAdditions)
- (NSImage *) iconForApplication:(NSString *) inName {
	NSString *path = [self fullPathForApplication:inName];
	NSImage *appIcon = path ? [self iconForFile:path] : nil;
	
	if ( appIcon ) {
		[appIcon setSize:NSMakeSize(128.0f,128.0f)];
	}
	return appIcon;
}
@end

// -----------------------------------------------------------------------------

// COPYRIGHT AND PERMISSION NOTICE
//
// Copyright ¬© 2003 Karelia Software, LLC. All rights reserved.
//
// Permission to use, copy, modify, and distribute this software for any purpose 
// with or without fee is hereby granted, provided that the above copyright
// notice and this permission notice appear in all copies.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT OF THIRD PARTY RIGHTS.
// IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, 
// DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR 
// OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE
// OR OTHER DEALINGS IN THE SOFTWARE.
//
// Except as contained in this notice, the name of a copyright holder shall not 
// be used in advertising or otherwise to promote the sale, use or other dealings
// in this Software without prior written authorization of the copyright holder.
static NSString* ellipsis = 0;

@implementation NSAttributedString (Truncation)
/*"	Truncate a string, returning substring with "…" to fit in the given width.  
Probably not the most efficient way of doing this; perhaps an optimization 
would be to decide on the font of the "É" and compensate for that in the 
width calculations; another would be to do a binary search on the length, 
zeroing in on the optimum length.
"*/
- (NSAttributedString *)truncateForWidth:(float) inWidth
{
	NSAttributedString* result = self;
	NSRange range;	
	
	// Commented out for leak testing...
	if ([self size].width > inWidth)
	{
		if(!ellipsis)
			ellipsis = [[NSString stringWithFormat:@"%C", 0x2026] retain];
		
		NSMutableAttributedString* newString = [[[NSMutableAttributedString 
			alloc] init] autorelease];
		int curLength = [self length] - 1;	//start by chopping off at least one
		
		[newString appendAttributedString:self];
		while ([newString size].width > inWidth)
		{
			// replace 2 characters with "…"
			range = NSMakeRange( curLength - 1, 2);	
			[newString replaceCharactersInRange:range withString:ellipsis];
			curLength--;
		}
		result = newString;
	}
	return result;
}

@end

// -----------------------------------------------------------------------------

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

/*"	Set inView to be the subview of self.  If there is currently no subview, it 
    is impossible to properly size the subview to fit within the subview.
"*/

- (void) setSubview:(NSView *)inView
{
	NSArray *subviews = [self subviews];
	
	// Replace or insert subview if not the right one already
	if (0 == [subviews count])
	{
		//		NSLog(@"Adding single subview");
		[self addSubview:inView];		// ANY WAY TO AUTO-RESIZE IT?
	}
	else if ([subviews objectAtIndex:0] != inView)
	{
		NSView *oldSubview = [subviews objectAtIndex:0];
		NSRect frame = [oldSubview frame];
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
	id result = nil;
	NSArray *subviews = [self subviews];
	if ([subviews count])
	{
		result = [subviews objectAtIndex:0];
	}
	return result;
}

@end

// -----------------------------------------------------------------------------

