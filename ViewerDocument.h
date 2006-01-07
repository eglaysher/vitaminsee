//
//  ViewerDocument.h
//  Prototype
//
//  Created by Elliot Glaysher on 8/11/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "FileList.h"

@class VitaminSEEWindowController;

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
-(void)focusOnFile:(EGPath*)path;

-(NSString*)scaleMode;
-(float)pixelWidth;
-(float)pixelHeight;
@end
