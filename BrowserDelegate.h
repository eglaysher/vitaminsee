//
//  BrowserDelegate.h
//  CQView
//
//  Created by Elliot on 1/27/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CQViewController.h"

@interface CQViewController (BrowserDelegate)

// Browser Delegation methods
- (id)browser:(NSBrowser*)browser numberOfRowsInColumn:(int)numberOfRows;
- (void)browser:(NSBrowser *)sender willDisplayCell:(id)cell 
		  atRow:(int)row column:(int)column;

// Internal helper methods
- (NSString*)fsPathToColumn:(int)column;

@end
