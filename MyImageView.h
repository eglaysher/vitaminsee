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

#import <Cocoa/Cocoa.h>

@interface MyImageView : NSImageView
{
    NSPoint startPt;
    NSPoint startOrigin;
}

@end

