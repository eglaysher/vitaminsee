/////////////////////////////////////////////////////////////////////////
// File:          $Name$
// Module:        implementation of the plugin layer
// Part of:       VitaminSEE
//
// Revision:      $Revision$
// Last edited:   $Date$
// Author:        $Author$
// Copyright:     (c) 2005 Elliot Glaysher
// Created:       4/7/05
//
/////////////////////////////////////////////////////////////////////////
//
// This library is free software; you can redistribute it and/or
// modify it under the terms of the GNU Lesser General Public
// License as published by the Free Software Foundation; either
// version 2.1 of the License, or (at your option) any later version.
//  
// This library is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
// Lesser General Public License for more details.
//  
// You should have received a copy of the GNU Lesser General Public
// License along with this library; if not, write to the Free Software
// Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  
// USA
//
/////////////////////////////////////////////////////////////////////////


#import "PluginLayer.h"
#import "VitaminSEEController.h"
#import "VitaminSEEController+PluginLayer.h"

#import "EGPath.h"

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

-(EGPath*)pathWithPath:(NSString*)inPath
{
	return [EGPathFilesystemPath pathWithPath:inPath];
}

@end
