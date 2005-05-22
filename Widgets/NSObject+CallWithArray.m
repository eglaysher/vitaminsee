//
//  NSObject+CallWithArray.m
//  VitaminSEE
//
//  Created by Elliot Glaysher on 5/21/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "NSObject+CallWithArray.h"


@implementation NSObject (CallWithArray)

-(void)performSelector:(SEL)selector withEachObjectIn:(NSArray*)arrayOfObjects
{
	CFArrayRef ref = (CFArrayRef)arrayOfObjects;
	int i = 0, count = CFArrayGetCount(ref);
	for(; i < count; ++i)
		[self performSelector:selector withObject:(id)CFArrayGetValueAtIndex(ref, i)];
}

@end
