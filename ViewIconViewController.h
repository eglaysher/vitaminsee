//
//  ViewIconViewController.h
//  CQView
//
//  Created by Elliot on 2/9/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@class VitaminSEEController;
@class ThumbnailManager;

@interface ViewIconViewController : NSObject {

	IBOutlet VitaminSEEController* controller;
	IBOutlet NSBrowser* ourBrowser;
	IBOutlet NSView* ourView;
	
	NSCell* currentlySelectedCell;
	NSString* currentDirectory;
	NSMutableArray* fileList;
	
	ThumbnailManager* thumbnailManager;
//	ImageTaskManager* imageTaskManager;
}

-(void)setThumbnailManager:(ThumbnailManager*)itm;

-(BOOL)canDelete;

-(void)setCurrentDirectory:(NSString*)path;
-(NSView*)view;

// Methods to handle clicks
-(void)singleClick:(NSBrowser*)sender;
-(void)doubleClick:(NSBrowser*)sender;

-(void)removeFile:(NSString*)absolutePath;
-(void)addFile:(NSString*)path;

-(NSString*)nameOfNextFile;
-(void)selectFile:(NSString*)fileToSelect;
-(void)updateCell:(id)cell;

-(void)makeFirstResponderTo:(NSWindow*)window;

-(void)clearCache;
-(void)setThumbnail:(NSImage*)image 
			forFile:(NSString*)path;


@end
