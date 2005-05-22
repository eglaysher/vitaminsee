//
//  NSObject+CallWithArray.h
//  VitaminSEE
//
//  Created by Elliot Glaysher on 5/21/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSObject (CallWithArray)
-(void)performSelector:(SEL)selector withEachObjectIn:(NSArray*)arrayOfObjects;
@end
