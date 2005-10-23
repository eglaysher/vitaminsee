/////////////////////////////////////////////////////////////////////////
// File:          $Name$
// Module:        Implements the drop down sheet asking for a folder name that's
//                accessable from Go > Goto Folder...
// Part of:       VitaminSEE
//
// Revision:      $Revision$
// Last edited:   $Date$
// Author:        $Author$
// Copyright:     (c) 2005 Elliot Glaysher
// Created:       3/10/05
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
}

-(IBAction)type:(id)sender
{
// Why isn't there anything here?
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
	[inTarget retain];
	[target release];
	target = inTarget;
	
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
		[target performSelector:returnSelector withObject:directory];

	[target release];
}

@end
