//
//  KeywordManager.h
//  CQView
//
//  Created by Elliot on 3/3/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "FileManager.h"

@class KeywordNode;

@interface KeywordManagerController : NSWindowController <FileManagerPlugin>
{
	IBOutlet NSTextField* fileNameTextField;
	IBOutlet NSTextView* currentKeywordsTextView;
	IBOutlet NSOutlineView* outlineView;
	
	CQViewController* pluginLayer;
	NSString* currentPath;
	NSMutableArray* keywords;
	
	KeywordNode* keywordRoot;
}

-(IBAction)cellClicked:(id)sender;
-(IBAction)keywordTextViewChanged:(id)sender;
-(IBAction)fileChanged:(id)sender;

-(void)loadKeywordTree;
-(void)loadKeywordsIntoTextViewFromList;
-(void)loadKeywordsIntoListFromTextView;

-(void)fileSetTo:(NSString*)newPath;

// Get the plugin name
-(NSString*)name;

// Most plugins will have a show window
-(void)activate;

// Context menu items for this plugin.
-(NSArray*)contextMenuItems;

@end
