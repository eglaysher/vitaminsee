/////////////////////////////////////////////////////////////////////////
// File:          $URL$
// Module:        Document object for a viewer window.
// Part of:       VitaminSEE
//
// ID:            $Id: ApplicationController.m 123 2005-04-18 00:21:02Z elliot $
// Revision:      $Revision$
// Last edited:   $Date$
// Author:        $Author$
// Copyright:     (c) 2005 Elliot Glaysher
// Created:       8/11/05
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

#import "FileList.h"

@class VitaminSEEWindowController;
@class EGPath;

// Notifications that are posted to a ViewerDocument's NotificationCenter

#define EGViewerImageFileSet @"EGViewerImageFileSet"
#define EGViewerWindowBecameMainWindow @"EGViewerWindowBecameMainWindow"
#define EGViewerWindowLostMainWindow @"EGViewerWindowLostMainWindow"
#define EGViewerWindowClosed @"EGViewerWindowClosed"

@interface ViewerDocument : NSDocument <FileListDelegate> {
	VitaminSEEWindowController* window;
	
	NSNotificationCenter* viewerNotifications;
	
	// The document ID. This is how we identify ourselves. This doesn't change
	NSNumber* documentID;
	
	// The document owns the current file list
	NSString* fileListName;
	id<FileList> fileList;
	
	// CurrentFile we're looking at.
	EGPath* currentFile;
	
	// Scale data
	NSString* scaleMode;
	float scaleRatio;
	
	// Used during resizing
	float oldFileListSize;
	
	// Image data
	float pixelWidth, pixelHeight;
}

-(id)init;
-(id)initWithPath:(EGPath*)path;

-(NSNumber*)documentID;

-(void)setDirectory:(EGPath*)path;
-(EGPath*)currentFile;
-(void)startProgressIndicator;
-(void)stopProgressIndicator;

-(void)redraw;

-(BOOL)validateSetAsDesktopImageItem:(NSMenuItem*)item;
-(BOOL)validateAction:(SEL)action;

-(void)setDirectoryFromRawPath:(NSString*)path;
-(BOOL)focusOnFile:(EGPath*)path;

-(NSString*)scaleMode;
-(float)pixelWidth;
-(float)pixelHeight;
@end
