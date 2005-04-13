//
//  PathExistsValueTransformer.m
//  VitaminSEE
//
//  Created by Elliot on 4/11/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "PathExistsValueTransformer.h"
#import "NSString+FileTasks.h"


@implementation PathExistsValueTransformer
+(Class)transformedValueClass
{
	return [NSNumber class];
}

+(BOOL)allowsReverseTransformation
{
	return NO;
}

-(id)transformedValue:(id)value
{
	if([value isDir])
		return [NSNumber numberWithBool:YES];
	else
		return [NSNumber numberWithBool:NO];
}


@end
