//
//  NSAttributedString+Truncation.m
//  CQView
//
//  Created by Elliot on 2/19/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

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

#import "NSAttributedString+Truncation.h"


@implementation NSAttributedString (Truncation)

/*"	Truncate a string, returning substring with "…" to fit in the given width.  
	Probably not the most efficient way of doing this; perhaps an optimization 
	would be to decide on the font of the "É" and compensate for that in the 
	width calculations; another would be to do a binary search on the length, 
	zeroing in on the optimum length.
"*/
- (NSAttributedString *)truncateForWidth:(int) inWidth
{
	NSAttributedString* result = self;
	
	// Commented out for leak testing...
	if ([self size].width > inWidth)
	{
		NSMutableAttributedString* newString = [[[NSMutableAttributedString alloc] init] autorelease];
		int curLength = [self length] - 1;	// start by chopping off at least one
		NSString* ellipsis = [NSString stringWithFormat:@"%C", 0x2026];
		
		[newString appendAttributedString:self];
		while ([newString size].width > inWidth)
		{
			NSRange range = NSMakeRange( curLength - 1, 2);	// replace 2 characters with "…"
			[newString replaceCharactersInRange:range withString:ellipsis];
			curLength--;
		}
		result = newString;
	}
	return result;
}

@end
