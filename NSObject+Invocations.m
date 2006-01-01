//
//  NSObject+Invocations.m
//  VitaminSEE
//
//  Created by Elliot Glaysher on 12/25/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "NSObject+Invocations.h"

//////////
@interface EGPerformOnMainThreadTrampoline : NSProxy {
	id object;
	id returnObject;
	BOOL waitUntilDone;
}

-(id)initWithObject:(id)inobject waitUntilDone:(BOOL)wait;
@end

@implementation EGPerformOnMainThreadTrampoline

-(id)initWithObject:(id)inobject waitUntilDone:(BOOL)wait
{
	object = [inobject retain];
	waitUntilDone = wait;

	return self;
}

-(void)dealloc
{
	[object release];
	[super dealloc];
}

-(id)fakeInvocationReturningSelector {
    return returnObject;
}

-(void)forwardInvocation:(NSInvocation *)anInvocation 
{
	if(!waitUntilDone)
		[anInvocation retainArguments];

	[object performSelectorOnMainThread:@selector(handleInvocation:)
							 withObject:anInvocation 
						  waitUntilDone:waitUntilDone];		
}

-(NSMethodSignature*)methodSignatureForSelector:(SEL)aSelector
{
    return [object methodSignatureForSelector:aSelector];
}

@end

@implementation NSObject (Invocations)

-(id)performOnMainThreadWaitUntilDone:(BOOL)wait
{
	return [[[EGPerformOnMainThreadTrampoline alloc] initWithObject:self waitUntilDone:wait] autorelease];
}

-(void)handleInvocation:(NSInvocation *)anInvocation
{
	[anInvocation invokeWithTarget:self];
}

@end
