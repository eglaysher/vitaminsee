//
//  KeywordNode.m
//  CQView
//
//  Created by Elliot on 2/27/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "KeywordNode.h"


@implementation KeywordNode


-(id)init
{
	if(self = [super init])
	{
		keyword = [[NSString alloc] init];
		children = [[NSMutableArray alloc] init];
	}
	
	return self;
}

-(id)initWithKeyword:(NSString*)inKeyword
{
	if(self = [super init])
	{
		keyword = [inKeyword retain];
		children = [[NSMutableArray alloc] init];
	}
	
	return self;	
}

-(void)dealloc
{
	[keyword release];
	[children release];
}

///// Encoding...
- (id)initWithCoder:(NSCoder *)decoder
{
//	self = [super initWithCoder:decoder];
	
    if([decoder allowsKeyedCoding])
	{
        // Can decode keys in any order
		keyword = [[decoder decodeObjectForKey:@"Keyword"] copy];
		children = [[decoder decodeObjectForKey:@"Children"] copy];
    } 
	else
	{		
		keyword = [[decoder decodeObject] copy];
		children = [[decoder decodeObject] copy];
    }
	
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
//	[super encodeWithCoder:encoder];
	
    if([encoder allowsKeyedCoding])
	{
		[encoder encodeObject:keyword forKey:@"Keyword"];
		[encoder encodeObject:children forKey:@"Children"];
    }
	else
	{
		[encoder encodeObject:keyword];
		[encoder encodeObject:children];
    }
}

// Accessors...
-(void)setKeyword:(NSString*)inKeyword
{
	[keyword release];
	keyword = inKeyword;
	[keyword retain];
}

-(NSString*)keyword
{
	return keyword;
}

-(int)numberOfChildren
{
	return [children count];
}

-(void)addChild:(id)child
{
	[children addObject:child];
}

-(NSArray*)children
{
	return children;
}

@end
