//
//  ViewIconViewController.h
//  CQView
//
//  Created by Elliot on 2/9/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@class VitaminSEEController;
@class ImageTaskManager;

@interface ViewIconViewController : NSObject {
	IBOutlet VitaminSEEController* controller;
	IBOutlet NSBrowser* ourBrowser;
	IBOutlet NSView* ourView;
	
	NSCell* currentlySelectedCell;
	NSString* currentDirectory;
	NSMutableArray* fileList;
	
	ImageTaskManager* imageTaskManager;
}

-(BOOL)canDelete;
-(void)setImageTaskManager:(ImageTaskManager*)itm;

-(void)setCurrentDirectory:(NSString*)path;
-(NSView*)view;

// Methods to handle clicks
-(void)singleClick:(NSBrowser*)sender;
-(void)doubleClick:(NSBrowser*)sender;

-(void)renameFile:(NSString*)absolutePath to:(NSString*)newPath;
-(void)removeFileFromList:(NSString*)absolutePath;
-(NSString*)nameOfNextFile;
-(void)selectFile:(NSString*)fileToSelect;
-(void)updateCell:(id)cell;

-(void)makeFirstResponderTo:(NSWindow*)window;

- (void)clearCache;
@end
