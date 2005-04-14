//
//  PluginLayer.m
//  VitaminSEE
//
//  Created by Elliot on 4/7/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "PluginLayer.h"
#import "VitaminSEEController.h"
#import "VitaminSEEController+PluginLayer.h"

@implementation PluginLayer

-(id)initWithController:(VitaminSEEController*)inController
{
	if(self = [super init])
	{
		// Don't retain, because VitaminSEEController is the parent!
		controller = inController;
	}
	
	return self;
}

+(id)pluginLayerWithController:(VitaminSEEController*)inController
{
	return [[[PluginLayer allocWithZone:NULL] initWithController:inController] autorelease];
}

// Metadata management functions (expand greatly!)
-(BOOL)supportsKeywords:(NSString*)file
{
	return [controller supportsKeywords:file];
}

-(NSMutableArray*)getKeywordsFromFile:(NSString*)file
{
	return [controller getKeywordsFromFile:file];
}

-(void)setKeywords:(NSArray*)keywords forFile:(NSString*)file
{
	[controller setKeywords:keywords forFile:file];
}

// File Management functions
-(NSString*)currentFile
{
	return [controller currentFile];
}

-(void)setCurrentFile:(NSString*)file
{
	[controller setCurrentFile:file];
}

-(void)preloadFile:(NSString*)file
{
	[controller preloadFile:file];
}

-(int)deleteFile:(NSString*)file
{
	return [controller deleteFile:file];
}

-(int)moveFile:(NSString*)file to:(NSString*)destination;
{
	return [controller moveFile:file to:destination];
}

-(int)copyFile:(NSString*)file to:(NSString*)destination
{
	return [controller copyFile:file to:destination];
}

-(BOOL)renameFile:(NSString*)file to:(NSString*)newName
{
	return [controller renameFile:file to:newName];
}

// Thumbnail functions
-(void)generateThumbnailForFile:(NSString*)path
{
	[controller generateThumbnailForFile:path];
}

-(void)clearThumbnailQueue
{
	[controller clearThumbnailQueue];
}

-(void)startProgressIndicator
{
	[controller startProgressIndicator];
}

-(void)stopProgressIndicator
{
	[controller stopProgressIndicator];
}

-(NSUndoManager*)pathManager
{
	return [controller pathManager];
}

-(NSUndoManager*)undoManager
{
	return [controller undoManager];
}

@end
