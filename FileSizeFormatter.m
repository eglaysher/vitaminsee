//
//  FileSizeFormatter.m
//  CQView
//
//  Created by Elliot on 2/2/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "FileSizeFormatter.h"

@implementation FileSizeFormatter

-(NSString*)stringForObjectValue:(id)obj
{
	long long bytes;
	
	if([obj isKindOfClass:[NSNumber class]])
		bytes = [obj longLongValue];
	else if([obj isKindOfClass:[NSString class]])
	{		
		// If we're passed a "none" placeholder, then use the placeholder...
		if([obj isEqualTo:@"---"])
		   return @"---";
		   
		bytes = [obj intValue];
	}
	else
		return nil;
	
	
	// If the file is empty, say so
	if(bytes == 0)
		return @"0 bytes";
	
	if(bytes < 1024)
		return [NSString stringWithFormat:@"%qi bytes", bytes];
	else if(bytes < 10485676)
		return [NSString stringWithFormat:@"%qi Kb", bytes/1024];
	else if(bytes < 1073741824)
		return [NSString stringWithFormat:@"%qi Mb", bytes/10485676];
	else
		return [NSString stringWithFormat:@"%qi Gb", bytes/1073741824];
}

-(BOOL)getObjectValue:(id *)obj forString:(NSString *)string 
	 errorDescription:(NSString **)error
{
	
}

-(NSAttributedString*)attributedStringForObjectValue:(id)anObject 
							   withDefaultAttributes:(NSDictionary*)attributes
{

	return [[[NSAttributedString alloc] 
		initWithString:[self stringForObjectValue:anObject] 
			attributes:attributes] autorelease];
}

@end
