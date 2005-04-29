/////////////////////////////////////////////////////////////////////////
// File:          $Name$
// Module:        Actual implementation of the methods in PluginLayer.
// Part of:       VitaminSEE
//
// Revision:      $Revision$
// Last edited:   $Date$
// Author:        $Author$
// Copyright:     (c) 2005 Elliot Glaysher
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
-(void)clearThumbnailQueue;

-(NSUndoManager*)pathManager;
-(NSUndoManager*)undoManager;

@end
