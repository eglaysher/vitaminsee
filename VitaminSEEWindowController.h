/////////////////////////////////////////////////////////////////////////
// File:          $URL$
// Module:        Window object for a viewer window.
// Part of:       VitaminSEE
//
// ID:            $Id: ApplicationController.m 123 2005-04-18 00:21:02Z elliot $
// Revision:      $Revision$
// Last edited:   $Date$
// Author:        $Author$
// Copyright:     (c) 2005 Elliot Glaysher
// Created:       7/31/05
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

@class VitaminSEEPicture;
@class RBSplitView;
@class ViewerDocument;
@class XeeStatusBar;
@class XeeStatusCell;
@class FileSizeFormatter;

@interface VitaminSEEWindowController : NSWindowController {
//	VitaminSEEPicture* pictureState;
    
	IBOutlet NSImageView *imageViewer;
	IBOutlet NSTextField * fileSizeLabel;
	IBOutlet NSTextField * imageSizeLabel;
	IBOutlet RBSplitView* splitView;
	IBOutlet NSScrollView* scrollView;
	
	// File view components:
	IBOutlet NSView* currentFileViewHolder;
	id<FileList> fileList;

	IBOutlet NSView* statusBarProgressIndicatorContainer;
	IBOutlet XeeStatusBar* statusbar;
	IBOutlet NSProgressIndicator* progressIndicator;
	bool currentlyAnimated;
	
	
	IBOutlet NSTextField * progressCurrentTask;
	
	float oldFileListSize;
	
	XeeStatusCell* zoomCell;
	XeeStatusCell* filesizeCell;
	FileSizeFormatter* formater;
	XeeStatusCell* imagesizeCell;
}
-(id)initWithFileList:(id<FileList>)inFileList;

-(void)setFileList:(id<FileList>)newList;

-(BOOL)statusBarHidden;

//-(IBAction)goToFolder:(id)sender;
//-(void)finishedGotoFolder:(NSString*)done;

-(void)beginCountdownToDisplayProgressIndicator;

-(void)startProgressIndicator;
-(void)stopProgressIndicator;

// File operations
//-(IBAction)deleteFileClicked:(id)sender;
//-(IBAction)addCurrentDirectoryToFavorites:(id)sender;

-(void)updateWindowTitle;

-(void)setImage:(NSImage*)image;
-(void)setFileSizeLabelText:(int)fileSize forPath:(EGPath*)path;
-(void)setImageSizeLabelText:(NSSize)size;

//-(IBAction)setImageAsDesktop:(id)sender;

-(double)viewingAreaWidth;
-(double)viewingAreaHeight;

-(float)nonImageWidthWithScrollbar:(BOOL)showScrollbar;
-(float)nonImageHeightWithScrollbar:(BOOL)showScrollbar;

-(BOOL)fileListHidden;
-(void)toggleStatusBar:(id)sender;

-(void)setFileListVisible:(BOOL)visible;

-(void)setZoomStatusBarCellFromTask:(id)task;
@end
