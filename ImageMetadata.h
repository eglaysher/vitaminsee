//
//  ImageMetadata.h
//  CQView
//
//  Created by Elliot on 3/3/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

// Image metadata is a ObjC wrapper around exiv2. 
@interface ImageMetadata : NSObject 
{}

+(NSMutableArray*)getKeywordsFromFile:(NSString*)file;
+(void)setKeywords:(NSArray*)keywords forFile:(NSString*)file;

@end
