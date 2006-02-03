//
//  RenameFileSheetController.m
//  VitaminSEE
//
//  Created by Elliot on 2/2/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "RenameFileSheetController.h"
#import "FileOperations.h"
#import "EGPath.h"
#import "ViewerDocument.h"

@implementation RenameFileSheetController

-(id)initWithFileOperations:(id)operations
{
	if(self = [super initWithWindowNibName:@"RenameFileSheet"])
	{
		[self window];
		
		// We don't retain because it's owned by the ComponentManager
		fileOperations = operations;
	}
	
	return self;
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
	initialValue:(EGPath*)initial
  notifyWhenDone:(id)document
{
	// First, set the callbacks for later when OUR callbacks are called
	initialPath = [initial retain];	
	doc = [document retain];
	
	// Clear the 
	NSString* firstName = [[initialPath fileSystemPath] lastPathComponent];
	[labelName setStringValue:[NSString stringWithFormat:@"Rename '%@' to:",
		firstName]];
	[folderName setStringValue:firstName];
	
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
	NSString* rawName = [folderName stringValue];
	
	// Close the sheet
	[sheet orderOut:self];	

	if(!cancel) 
	{
		// Disallow attempts to move directories by being clever
		if([rawName rangeOfString:@"/"].location != NSNotFound ||
		   [rawName isEqualTo:@""]) 
		{
			AlertSoundPlay();
			return;
		}
		
		if([fileOperations renameFile:initialPath to:rawName]) 
		{	
			// Rename succeded. Display this new file!
			NSString* newPath = [[[initialPath fileSystemPath]			
				stringByDeletingLastPathComponent] 
			stringByAppendingPathComponent:rawName];
			
			[doc focusOnFile:[EGPath pathWithPath:newPath]];
		}		
	}
	
	[initialPath release];
	[doc release];
}

@end
