/////////////////////////////////////////////////////////////////////////
// File:          $Name$
// Module:        Implements the View as icons file browser
// Part of:       VitaminSEE
//
// Revision:      $Revision$
// Last edited:   $Date$
// Author:        $Author$
// Copyright:     (c) 2005 Elliot Glaysher
// Created:       2/9/05
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

#import "FileView.h"

@class PluginLayer;
@class ThumbnailManager;

@interface ViewIconViewController : NSObject <FileView> {
	IBOutlet NSPopUpButton* directoryDropdown;
	IBOutlet NSBrowser* ourBrowser;
	IBOutlet NSView* ourView;

	PluginLayer* pluginLayer;
	
	NSCell* currentlySelectedCell;
	NSString* currentDirectory;
	NSArray* currentDirectoryComponents;
	
	NSMutableArray* fileList;	
	int oldPosition;
}

//-(void)setThumbnailManager:(ThumbnailManager*)itm;

-(void)setCurrentDirectory:(NSString*)directory currentFile:(NSString*)file;

//-(void)setCurrentDirectory:(NSString*)path;
-(NSView*)view;

// Methods to handle clicks
-(void)singleClick:(NSBrowser*)sender;
-(void)doubleClick:(NSBrowser*)sender;

-(void)removeFile:(NSString*)absolutePath;
-(void)addFile:(NSString*)path;

-(void)directoryMenuSelected:(id)sender;

-(NSString*)nameOfNextFile;
-(void)selectFile:(NSString*)fileToSelect;
-(void)updateCell:(id)cell;

-(void)makeFirstResponderTo:(NSWindow*)window;

-(void)clearCache;
-(void)setThumbnail:(NSImage*)image 
			forFile:(NSString*)path;


@end
