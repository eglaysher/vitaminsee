//
//  KeywordNode.m
//  CQView
//
//  Created by Elliot on 2/27/05.
//  Copyright 2005 Elliot Glaysher. All rights reserved.
//

#import "KeywordNode.h"


@implementation KeywordNode


-(id)initWithParent:(KeywordNode*)inParent
{
	if(self = [super init])
	{
		parent = inParent; // NOTE THAT WE DO NOT RETAIN PARENT FOR FEAR OF CYCLES!
		keyword = [[NSString alloc] init];
		children = [[NSMutableArray alloc] init];
	}
	
	return self;
}

-(id)initWithParent:(KeywordNode*)inParent 
			keyword:(NSString*)inKeyword
{
	if(self = [super init])
	{
		parent = inParent; // NOTE THAT WE DO NOT RETAIN PARENT FOR FEAR OF CYCLES!
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
		children = [[decoder decodeObjectForKey:@"Children"] mutableCopy];
		parent = [decoder decodeObjectForKey:@"Parent"];
    } 
	else
	{		
		keyword = [[decoder decodeObject] mutableCopy];
		children = [[decoder decodeObject] mutableCopy];
		parent = [decoder decodeObject];
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
		[encoder encodeObject:parent forKey:@"Parent"];
    }
	else
	{
		[encoder encodeObject:keyword];
		[encoder encodeObject:children];
		[encoder encodeObject:parent];
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

-(KeywordNode*)parent
{
	return parent;
}

-(void)addChild:(id)child
{
	[children addObject:child];
}

-(void)removeChild:(id)child
{
	[children removeObject:child];
}

-(NSArray*)children
{
	return children;
}

@end
