//
//  Util.m
//  CQView
//
//  Created by Elliot on 2/6/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "Util.h"
#import <stdlib.h>

float buildRatio(float first, float second)
{
	float firstRatio = first / second;
	float secondRatio = second / first;
	return min(secondRatio, firstRatio);
}

BOOL imageRepIsAnimated(NSImageRep* rep)
{
	if([rep isKindOfClass:[NSBitmapImageRep class]] &&
	   [[rep valueForProperty:NSImageFrameCount] intValue] > 1)
		return YES;
	else
		return NO;
}