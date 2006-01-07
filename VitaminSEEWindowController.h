//
//  VitaminSEEWindowController.h
//  VitaminSEE
//
//  Created by Elliot Glaysher on 7/31/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "FileList.h"

@class VitaminSEEPicture;
@class RBSplitView;
@class ViewerDocument;

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
	
	IBOutlet NSProgressIndicator* progressIndicator;
	bool currentlyAnimated;
	
	IBOutlet NSTextField * progressCurrentTask;
	
	NSCursor *handCursor;
	NSUndoManager* pathManager;	
	
	float oldFileListSize;
}
-(id)initWithFileList:(id<FileList>)inFileList
			 document:(ViewerDocument*)viewerDocument;

-(void)setFileList:(id<FileList>)newList;

//-(IBAction)goToFolder:(id)sender;
//-(void)finishedGotoFolder:(NSString*)done;

-(void)startProgressIndicator;
-(void)stopProgressIndicator;

// File operations
//-(IBAction)deleteFileClicked:(id)sender;
//-(IBAction)addCurrentDirectoryToFavorites:(id)sender;

-(void)updateWindowTitle;

-(void)setImage:(NSImage*)image;
-(void)setFileSizeLabelText:(int)fileSize;
-(void)setImageSizeLabelText:(NSSize)size;

//-(IBAction)setImageAsDesktop:(id)sender;

-(double)viewingAreaWidth;
-(double)viewingAreaHeight;

-(float)nonImageWidth;
-(float)nonImageHeight;

@end
