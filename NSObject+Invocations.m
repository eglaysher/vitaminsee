/////////////////////////////////////////////////////////////////////////
// File:          $URL$
// Module:        Trampoline to run on main thread
// Part of:       VitaminSEE
//
// Revision:      $Revision$
// Last edited:   $Date$
// Author:        $Author$
// Copyright:     (c) 2005 Elliot Glaysher
// Created:       12/25/05
//
/////////////////////////////////////////////////////////////////////////
//
// This program is free software; you can redistribute it and/or
// modify it under the terms of the GNU General Public License
// as published by the Free Software Foundation; either version 2
// of the License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program; if not, write to the Free Software
// Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
//
////////////////////////////////////////////////////////////////////////

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
