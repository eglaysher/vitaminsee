//
//  ViewIconViewController.h
//  CQView
//
//  Created by Elliot on 2/9/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class CQViewController;
@class ImageTaskManager;

@interface ViewIconViewController : NSObject {
	IBOutlet CQViewController* controller;
	IBOutlet NSBrowser* ourBrowser;
	IBOutlet NSView* ourView;
	
	NSCell* currentlySelectedCell;
	NSString* currentDirectory;
	NSMutableArray* fileList;
	
	ImageTaskManager* imageTaskManager;
}

-(void)setCurrentDirectory:(NSString*)path;
-(NSView*)view;

// Implement the NSBrowser delegate protocal
- (int)browser:(NSBrowser *)sender numberOfRowsInColumn:(int)column;
- (void)browser:(NSBrowser *)sender willDisplayCell:(id)cell 
		  atRow:(int)row column:(int)column;

// Methods to handle clicks
-(void)singleClick:(NSBrowser*)sender;
-(void)doubleClick:(NSBrowser*)sender;

-(void)removeFileFromList:(NSString*)absolutePath;
-(NSString*)nameOfNextFile;
-(void)selectFile:(NSString*)fileToSelect;
-(void)setThumbnail:(NSImage*)thumbnail
			forFile:(NSString*)file
				row:(int)row;
@end
