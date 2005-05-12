//
//  EGScrollView.h
//  VitaminSEE
//
//  Created by Elliot Glaysher on 5/11/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface EGScrollView : NSScrollView {
	BOOL shouldDrawFocusRing; 
    NSResponder *lastResp;
}

-(void)noteMouseDown;
-(void)scrollTheViewByX:(float)x y:(float)y;
@end
