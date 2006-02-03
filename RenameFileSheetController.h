//
//  RenameFileSheetController.h
//  VitaminSEE
//
//  Created by Elliot on 2/2/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class EGPath;

@interface RenameFileSheetController : NSWindowController {
	IBOutlet NSTextField* labelName;
	IBOutlet NSTextField* folderName;
	
	bool cancel;
	EGPath* initialPath;
	
	id fileOperations;
	id doc;
}

-(id)initWithFileOperations:(id)operations;

-(IBAction)clickOK:(id)sender;
-(IBAction)clickCancel:(id)sender;

-(void)showSheet:(NSWindow*)window 
	initialValue:(EGPath*)initial
  notifyWhenDone:(id)document;


@end
