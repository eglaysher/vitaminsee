//
//  ImmutableToMutableTransformer.m
//  CQView
//
//  Created by Elliot on 2/22/05.
//  Copyright 2005 Elliot Glaysher. All rights reserved.
//

#import "ImmutableToMutableTransformer.h"


@implementation ImmutableToMutableTransformer

+(Class)transformedValueClass
{
	return [NSMutableArray class];
}

+(BOOL)allowsReverseTransformation
{
	return YES;
}

-(id)transformedValue:(id)value
{
	if(value == nil)
		return nil;
	
	NSMutableArray* array = [NSMutableArray arrayWithCapacity:[value count]];
	NSEnumerator* e = [value objectEnumerator];
	id object;
	while(object = [e nextObject])
		[array addObject:[[object mutableCopy] autorelease]];
			
	return array;
}

@end
