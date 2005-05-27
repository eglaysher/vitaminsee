/////////////////////////////////////////////////////////////////////////
// File:          $Name$
// Module:        Node in which keywords for the Keyword Manager are stored in.
// Part of:       VitaminSEE
//
// Revision:      $Revision$
// Last edited:   $Date$
// Author:        $Author$
// Copyright:     (c) 2005 Elliot Glaysher
// Created:       2/27/05
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
	[super dealloc];
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
	[inKeyword retain];
	[keyword release];
	keyword = inKeyword;
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
