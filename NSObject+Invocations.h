//
//  NSObject+Invocations.h
//  VitaminSEE
//
//  Created by Elliot Glaysher on 12/25/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSObject (Invocations)
-(id)performOnMainThreadWaitUntilDone:(BOOL)wait;
-(void)handleInvocation:(NSInvocation *)anInvocation;
@end
