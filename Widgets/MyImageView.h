/////////////////////////////////////////////////////////////////////////
// File:          $URL$
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

@class EGScrollView;

enum EGScrollViewLocation {
	// x, y
	EGSV_NONE,
	EGSV_LEFT_CENTER,
	EGSV_RIGHT_CENTER,
	EGSV_CENTER_TOP,
	EGSV_CENTER_BOTTOM
};

@interface MyImageView : NSImageView
{
    NSPoint startPt;
    NSPoint startOrigin;
	enum EGScrollViewLocation nextImageStartingLocation;
	
	BOOL waiting;

	IBOutlet EGScrollView* scrollView;	
}

-(void)setNextImageStartingLocation:(enum EGScrollViewLocation)location;

-(BOOL)waitingForImage;
-(void)setWaitingForImage:(BOOL)waiting;

@end

