/////////////////////////////////////////////////////////////////////////
// File:          $Name$
// Module:        Implements the drop down sheet asking for a folder name that's
//                accessable from Go > Goto Folder...
// Part of:       VitaminSEE
//
// Revision:      $Revision: 284 $
// Last edited:   $Date: 2005-10-23 11:29:01 -0500 (Sun, 23 Oct 2005) $
// Author:        $Author: elliot $
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

#import "GotoFolderWindowController.h"
#import "EGPath.h"
#import "NSString+FileTasks.h"

@implementation GotoFolderWindowController

-(id)init
{
	if(self = [super initWithWindowNibName:@"GotoFolderWindow"])
	{
		// Force loading of the window object.
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

//-----------------------------------------------------------------------------

/** Handles the OK button on the modal "Go to folder" window.
 *
 */
-(IBAction)clickOK:(id)sender
{
	// Let's grab the data out of the text box and call the selector with an
	// NSString of the target directory
	NSString* directory = [[folderName stringValue] stringByExpandingTildeInPath];	

	[[self window] orderOut:self];
	[NSApp stopModal];

	if([directory isDir]) 
	{
		id egpath = [EGPath pathWithPath:directory];
		
		[target performSelector:returnSelector withObject:egpath];	
	}
}

//-----------------------------------------------------------------------------

/** 
 *
 */
-(IBAction)clickCancel:(id)sender
{
	[[self window] orderOut:self];
	[NSApp stopModal];
}

//-----------------------------------------------------------------------------

/** 
 *
 */
-(void)showModalWindowWithInitialValue:(NSString*)initialValue
								target:(id)inTarget 
							  selector:(SEL)selector
{
	target = inTarget;
	returnSelector = selector;
	
	[folderName setStringValue:initialValue];
	
	[NSApp runModalForWindow:[self window]];
}

@end
