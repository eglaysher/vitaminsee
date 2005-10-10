//
//  Util.h
//  Prototype
//
//  Created by Elliot Glaysher on 9/18/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#ifdef __cplusplus
extern "C"
{
#endif        /* __cplusplus */

NSNumber* buildRatio(float first, float second);
BOOL imageRepIsAnimated(NSImageRep* rep);
BOOL floatEquals(float one, float two, float tolerance);

#ifdef __cplusplus
}
#endif        /* __cplusplus */
	