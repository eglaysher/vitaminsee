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
	NSEnumerator* e = [arrayOfObjects objectEnumerator];
	id object;
	while(object = [e nextObject])
		[self performSelector:selector withObject:object];
}

@end
