//
//  FullscreenWindowController.h
//  VitaminSEE
//
//  Created by Elliot on 2/12/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

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
-(void)setFileSizeLabelText:(int)fileSize;
-(void)setImageSizeLabelText:(NSSize)size;

// These should return the size of the screen.
-(double)viewingAreaWidth;
-(double)viewingAreaHeight;

-(void)becomeFullscreen;
@end
