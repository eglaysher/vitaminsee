//
//  ViewIconViewController.h
//  CQView
//
//  Created by Elliot on 2/9/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class CQViewController;

@interface ViewIconViewController : NSObject {
	IBOutlet CQViewController* controller;
	IBOutlet NSBrowser* ourBrowser;
	IBOutlet NSView* ourView;
	
	NSString* currentDirectory;
	NSArray* fileList;
}

-(NSView*)view;
-(void)setCurrentDirectory:(NSString*)path;

// Implement the NSBrowser delegate protocal
- (int)browser:(NSBrowser *)sender numberOfRowsInColumn:(int)column;
- (void)browser:(NSBrowser *)sender 
willDisplayCell:(id)cell 
		  atRow:(int)row
		 column:(int)column;

// Methods to handle clicks
-(void)singleClick:(NSBrowser*)sender;
-(void)doubleClick:(NSBrowser*)sender;

@end
