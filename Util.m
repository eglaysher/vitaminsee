//
//  Util.m
//  Prototype
//
//  Created by Elliot Glaysher on 9/18/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "Util.h"
#include <stdint.h>

/** Utility function that inspects an image rep and tries to determine if it's
 * animated.
 */
BOOL imageRepIsAnimated(NSImageRep* rep)
{
	// This could possibly fix the animation issues.
	if([rep isKindOfClass:[NSBitmapImageRep class]] &&
	   ([[(NSBitmapImageRep*)rep valueForProperty:NSImageFrameCount] intValue] > 1 ||
		[[(NSBitmapImageRep*)rep valueForProperty:NSImageCurrentFrameDuration] floatValue] > 0.0f))
		return YES;
	else
		return NO;
}

//-----------------------------------------------------------------------------

/** Checks for equality of two floats (with some tolerance.)
 */
BOOL floatEquals(float one, float two, float tolerance)
{
	return fabs(one - two) < tolerance;
}

//-----------------------------------------------------------------------------

/** Checks to see if the path path is in Favorites.
 */
BOOL isInFavorites(NSString* path)
{
	BOOL inFavorites = NO;
	NSEnumerator* e = [[[NSUserDefaults standardUserDefaults]
			objectForKey:@"SortManagerPaths"] objectEnumerator];
	NSString* thisPath;
	while(thisPath = [[e nextObject] objectForKey:@"Path"])
	{
		if([thisPath isEqualTo:path])
		{
			inFavorites = YES;
			break;
		}
	}
	
	return inFavorites;
}
