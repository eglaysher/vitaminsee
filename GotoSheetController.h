//
//  GotoSheetController.h
//  VitaminSEE
//
//  Created by Elliot on 3/10/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface GotoSheetController : NSWindowController {
	IBOutlet NSTextField* folderName;
	NSTimer* timer;
	
	bool cancel;
	id target;
	SEL returnSelector;
}

-(void)showSheet:(NSWindow*)window 
	initialValue:(NSString*)initialValue
		  target:(id)inTarget 
		selector:(SEL)selector;

-(IBAction)type:(id)sender;
-(IBAction)clickOK:(id)sender;
-(IBAction)clickCancel:(id)sender;

-(void)completeText:(id)sender;

@end
