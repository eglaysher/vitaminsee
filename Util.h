//
//  Util.h
//  CQView
//
//  Created by Elliot on 2/6/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#define min(a,b) (((a)<(b))?(a):(b))

float buildRatio(float first, float second);
BOOL imageRepIsAnimated(NSImageRep* rep);