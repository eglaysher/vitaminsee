//
//  PluginLayer.h
//  CQView
//
//  Created by Elliot on 2/24/05.
//  Copyright 2005 Elliot Glaysher. All rights reserved.
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

-(BOOL)renameFile:(NSString*)file to:(NSString*)destination;

-(NSString*)currentFile;

-(int)deleteFile:(NSString*)file;
-(int)moveFile:(NSString*)file to:(NSString*)destination;
-(int)copyFile:(NSString*)file to:(NSString*)destination;

-(void)generateThumbnailForFile:(NSString*)path;

-(NSUndoManager*)pathManager;
-(NSUndoManager*)undoManager;

@end
