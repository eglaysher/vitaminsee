//
//  Util.h
//  CQView
//
//  Created by Elliot on 2/6/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#define min(a,b) (((a)<(b))?(a):(b))
struct DS {
	int width;
	int height;
};
struct DS buildImageSize(int boxWidth, int boxHeight, int imageWidth, int imageHeight,
					  BOOL canScaleProportionally, float ratioToScale,
					  BOOL*canGetAwayWithQuickRender, float* ratioUsed);
float buildRatio(int first, int second);
BOOL imageRepIsAnimated(NSImageRep* rep);
NSImage* buildImageFromNormalFile(NSString* path, NSSize size);