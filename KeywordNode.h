//
//  KeywordNode.h
//  CQView
//
//  Created by Elliot on 2/27/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface KeywordNode : NSObject <NSCoding>
{
	NSString* keyword;
	NSMutableArray* children;
	KeywordNode* parent;
}

-(id)initWithParent:(KeywordNode*)parent;
-(id)initWithParent:(KeywordNode*)parent keyword:(NSString*)inKeyword;

// NSCoding protocol
- (id)initWithCoder:(NSCoder *)decoder;
- (void)encodeWithCoder:(NSCoder *)encoder;

// Accessors...
-(void)setKeyword:(NSString*)inKeyword;
-(NSString*)keyword;
-(KeywordNode*)parent;

-(int)numberOfChildren;
-(NSArray*)children;
-(void)addChild:(id)child;
-(void)removeChild:(id)child;

@end
