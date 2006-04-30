/////////////////////////////////////////////////////////////////////////
// File:          $URL$
// Module:        Object that exposes the entire Fullscreen modlue
// Part of:       VitaminSEE
//
// Revision:      $Revision$
// Last edited:   $Date$
// Author:        $Author$
// Copyright:     (c) 2006 Elliot Glaysher
// Created:       2/12/06
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
// Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 
// 02110-1301, USA.
//
////////////////////////////////////////////////////////////////////////


#import <Cocoa/Cocoa.h>
#import "FileList.h"

@class ViewerDocument;
@class FileListWindowController;
@class FullScreenControlWindowController;

@interface FullscreenWindowController : NSWindowController {
	IBOutlet NSImageView *imageViewer;
	IBOutlet NSScrollView* scrollView;
	IBOutlet NSPanel* viewerPanel;

	// We own this because we have no other choice design wise.
	FileListWindowController* fileListViewerController;
	FullScreenControlWindowController* fullScreenControlWindowController;
	
	BOOL shouldRecordWindowState;
}

-(void)setFileList:(id<FileList>)newList;

-(void)recordWindowStates;

-(void)beginCountdownToDisplayProgressIndicator;
-(void)startProgressIndicator;
-(void)stopProgressIndicator;
-(void)updateWindowTitle;

-(void)setImage:(NSImage*)image;
//-(void)setFileSizeLabelText:(int)fileSize;
-(void)setImageSizeLabelText:(NSSize)size;

// These should return the size of the screen.
-(double)viewingAreaWidth;
-(double)viewingAreaHeight;

-(void)becomeFullscreen;

-(void)update;
@end
