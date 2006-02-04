//
//  HigherOrderMessaging.m
//  VitaminSEE
//
//  Created by Elliot on 12/31/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "HigherOrderMessaging.h"
#import "BSTrampoline.h"

@implementation NSArray(HigherOrderMessaging)

-(id)trampolineWithMode:(int)mode
{
	id obj;
	if([self count])
		obj = [self objectAtIndex:0];
	else
		obj = nil;
	
	return [[[BSTrampoline alloc] initWithEnumerator:[self objectEnumerator]
												mode:mode
										sampleObject:obj] autorelease];
}

- (id)do {
    return [self trampolineWithMode:kDoMode];
}

- (id)collect {
	return [self trampolineWithMode:kCollectMode];
}

- (id)select {
    return [self trampolineWithMode:kSelectMode];
}

- (id)reject {
	return [self trampolineWithMode:kRejectMode];
}

@end