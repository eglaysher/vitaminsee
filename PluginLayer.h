//
//  PluginLayer.h
//  CQView
//
//  Created by Elliot on 2/24/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "VitaminSEEController.h"

@interface VitaminSEEController (PluginLayer)

-(BOOL)supportsKeywords:(NSString*)file;
-(NSMutableArray*)getKeywordsFromFile:(NSString*)file;
-(void)setKeywords:(NSArray*)keywords forFile:(NSString*)file;

-(BOOL)renameThisFileTo:(NSString*)newName;

-(void)deleteThisFile;
-(int)deleteFile:(NSString*)file;

-(void)moveThisFile:(NSString*)destination;
-(int)moveFile:(NSString*)file to:(NSString*)destination;

-(void)copyThisFile:(NSString*)destination;
-(int)copyFile:(NSString*)file to:(NSString*)destination;

@end
