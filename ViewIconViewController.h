//
//  ViewIconViewController.h
//  CQView
//
//  Created by Elliot on 2/9/05.
//  Copyright 2005 Elliot Glaysher. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "FileView.h"

@class PluginLayer;
@class ThumbnailManager;

@interface ViewIconViewController : NSObject <FileView> {
	IBOutlet NSPopUpButton* directoryDropdown;
	IBOutlet NSBrowser* ourBrowser;
	IBOutlet NSView* ourView;

	PluginLayer* pluginLayer;
	
	NSCell* currentlySelectedCell;
	NSString* currentDirectory;
	NSArray* currentDirectoryComponents;
	
	NSMutableArray* fileList;	
	int oldPosition;
}

//-(void)setThumbnailManager:(ThumbnailManager*)itm;

-(void)setCurrentDirectory:(NSString*)directory currentFile:(NSString*)file;

//-(void)setCurrentDirectory:(NSString*)path;
-(NSView*)view;

// Methods to handle clicks
-(void)singleClick:(NSBrowser*)sender;
-(void)doubleClick:(NSBrowser*)sender;

-(void)removeFile:(NSString*)absolutePath;
-(void)addFile:(NSString*)path;

-(void)directoryMenuSelected:(id)sender;

-(NSString*)nameOfNextFile;
-(void)selectFile:(NSString*)fileToSelect;
-(void)updateCell:(id)cell;

-(void)makeFirstResponderTo:(NSWindow*)window;

-(void)clearCache;
-(void)setThumbnail:(NSImage*)image 
			forFile:(NSString*)path;


@end
