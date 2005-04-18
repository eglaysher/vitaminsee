//
//  ImageMetadata.h
//  CQView
//
//  Created by Elliot on 3/3/05.
//  Copyright 2005 Elliot Glaysher. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "PluginBase.h"

@interface ImageMetadata : NSObject <PluginBase>
{}

// ObjC wrapper around exiv2. 
-(NSMutableArray*)getKeywordsFromJPEGFile:(NSString*)file;
-(void)setKeywords:(NSArray*)keywords forJPEGFile:(NSString*)file;

@end
