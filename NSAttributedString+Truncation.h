//
//  NSAttributedString+Truncation.h
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

#import <Cocoa/Cocoa.h>


@interface NSAttributedString (Truncation)
-(NSAttributedString*)truncateForWidth:(int)inWidth;
@end
