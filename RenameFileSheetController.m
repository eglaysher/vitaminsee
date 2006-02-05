/////////////////////////////////////////////////////////////////////////
// File:          $Name$
// Module:        Implements the renaming sheet. Ripped off from GotoFileSheet.
// Part of:       VitaminSEE
//
// Revision:      $Revision: 331 $
// Last edited:   $Date: 2006-01-24 21:36:22 -0600 (Tue, 24 Jan 2006) $
// Author:        $Author: elliot $
// Copyright:     (c) 2005 Elliot Glaysher
// Created:       2/2/06
//
/////////////////////////////////////////////////////////////////////////
//
// This program is free software; you can redistribute it and/or
// modify it under the terms of the GNU General Public License
// as published by the Free Software Foundation; either version 2
// of the License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program; if not, write to the Free Software
// Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
//
////////////////////////////////////////////////////////////////////////

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
			
			[self undoableFocusOnFile:newPath oldPath:initialPath doc:doc];
		}		
	}
	
	[initialPath release];
	[doc release];
}

-(void)undoableFocusOnFile:(NSString*)newPath oldPath:(EGPath*)oldPath
					   doc:(id)document
{
	// If we undo this rename, we want to make sure to focus on the old
	// file.
	NSUndoManager* um = [doc undoManager];
	[[um prepareWithInvocationTarget:self] undoableFocusOnFile:[oldPath fileSystemPath]
													   oldPath:[EGPath pathWithPath:newPath]
														   doc:document];
	[document focusOnFile:[EGPath pathWithPath:newPath]];	
}

@end
