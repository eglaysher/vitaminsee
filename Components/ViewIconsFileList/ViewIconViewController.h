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
// This program is free software; you can redistribute it and/or
// modify it under the terms of the GNU General Public License
// as published by the Free Software Foundation; either version 2
// of the License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program; if not, write to the Free Software
// Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
//
////////////////////////////////////////////////////////////////////////


#import <Cocoa/Cocoa.h>

#import "FileView.h"

@class PluginLayer;
@class ThumbnailManager;
@class EGPath;

@interface ViewIconViewController : NSObject <FileView> {
	IBOutlet NSPopUpButton* directoryDropdown;
	IBOutlet NSBrowser* ourBrowser;
	IBOutlet NSView* ourView;

	PluginLayer* pluginLayer;
	
	NSCell* currentlySelectedCell;
	EGPath* currentDirectory;
	
	NSMutableArray* fileList;	
	NSMutableDictionary* thumbnailCache;
	int oldPosition;
	
	BOOL needToRebuild;
}

-(void)connectKeyFocus:(id)nextFocus;

//-(void)setThumbnailManager:(ThumbnailManager*)itm;

-(void)setCurrentDirectory:(EGPath*)directory currentFile:(NSString*)file;

//-(void)setCurrentDirectory:(NSString*)path;
-(NSView*)view;

// Methods to handle clicks
-(void)singleClick:(id)sender;
-(void)doubleClick:(id)sender;

-(void)removeFile:(NSString*)absolutePath;
-(void)addFile:(NSString*)path;

-(void)directoryMenuSelected:(id)sender;

-(NSString*)nameOfNextFile;
-(void)selectFile:(NSString*)fileToSelect;

-(void)makeFirstResponderTo:(NSWindow*)window;

-(void)removeUnneededImageReps:(NSImage*)image;

-(void)clearCache;
-(void)setThumbnail:(NSImage*)image 
			forFile:(NSString*)path;

@end
