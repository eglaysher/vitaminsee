//
//  PluginLayer.h
//  CQView
//
//  Created by Elliot on 2/24/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "VitaminSEEController.h"

// Make this a PluginLayer a class that calls these methods on 
// VitaminSEEController.

@interface VitaminSEEController (PluginLayer)

// Keyword functions
-(BOOL)supportsKeywords:(NSString*)file;
-(NSMutableArray*)getKeywordsFromFile:(NSString*)file;
-(void)setKeywords:(NSArray*)keywords forFile:(NSString*)file;

-(BOOL)renameThisFileTo:(NSString*)newName;

-(NSString*)currentFile;
-(void)deleteThisFile;
-(void)moveThisFile:(NSString*)destination;
-(void)copyThisFile:(NSString*)destination;

-(int)deleteFile:(NSString*)file;
-(int)moveFile:(NSString*)file to:(NSString*)destination;
-(int)copyFile:(NSString*)file to:(NSString*)destination;

//-(void)generateThumbnailFor:(NSString*)path;

@end
