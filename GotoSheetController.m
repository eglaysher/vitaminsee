//
//  GotoSheetController.m
//  VitaminSEE
//
//  Created by Elliot on 3/10/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "GotoSheetController.h"


@implementation GotoSheetController

-(id)init
{
	if(self = [super initWithWindowNibName:@"GoToFolderSheet"])
	{
		[self window];
	}
	
	return self;
}

-(void)completeText:(id)sender
{
	NSString* fileNameToComplete = [folderName stringValue];
	
	NSArray* a;
	[fileNameToComplete completePathIntoString:nil
								 caseSensitive:NO
							  matchesIntoArray:&a
								   filterTypes:nil];
//	NSLog(@"Paths: %@", a);
}

-(IBAction)type:(id)sender
{
//	NSLog(@"type type type");
}

-(IBAction)clickOK:(id)sender
{
	cancel = false;
	[NSApp endSheet:[self window]];
}

-(IBAction)clickCancel:(id)sender
{
	cancel = true;
	[NSApp endSheet:[self window]];
}

-(void)showSheet:(NSWindow*)window 
	initialValue:(NSString*)initialValue
		  target:(id)inTarget 
		selector:(SEL)selector
{
	// First, set the callbacks for later when OUR callbacks are called
	target = inTarget;
	[target retain];
	returnSelector = selector;
	
	// Clear the 
	[folderName setStringValue:initialValue];

	[NSApp beginSheet:[self window]
	   modalForWindow:window
		modalDelegate:self
	   didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:)
		  contextInfo:nil];
}	


-(void)sheetDidEnd:(NSWindow*)sheet returnCode:(int)returnCode
	   contextInfo:(void*)contextInfo
{
	// Let's grab the data out of the text box and call the selector with an
	// NSString of the target directory
	NSString* directory = [[folderName stringValue] stringByExpandingTildeInPath];
	
	// Close the sheet
	[sheet orderOut:self];
	
	// Now call the selector on target if needed.
	if(!cancel)
	{
		[target performSelector:returnSelector withObject:directory];
	}
}

@end
