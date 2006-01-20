/////////////////////////////////////////////////////////////////////////
// File:          $Name$
// Module:        Implements the Sort Manager panel
// Part of:       VitaminSEE
//
// Revision:      $Revision$
// Last edited:   $Date$
// Author:        $Author$
// Copyright:     (c) 2005 Elliot Glaysher
// Created:       2/13/05
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

#import "SortManagerController.h"
#import "NSString+FileTasks.h"
#import "EGPath.h"
#import "ComponentManager.h"
#import "FileOperations.h"

@implementation SortManagerController

////////////////////////////////////////////////////////// PROTOCOL: PluginBase
-(id)init
{
	// Load the nib file
	if(self = [super initWithWindowNibName:@"SortManager"])
	{
		// stuff could go here.
		keyValues = [[NSMutableDictionary alloc] init];
	}
	
	return self;
}

-(void)dealloc
{
	[keyValues release];
	[super dealloc];
}

-(void)windowDidLoad
{
	[super windowDidLoad];
	
	[(NSPanel*)[self window] setBecomesKeyOnlyIfNeeded:YES];	
	[self setShouldCascadeWindows:NO];
	[self setWindowFrameAutosaveName:@"sortManagerWindowPosition"];
}

-(IBAction)moveButtonPushed:(id)sender
{
	int rowIndex = [sender selectedRow];
	id cellProperties = [[[NSUserDefaults standardUserDefaults] 
		objectForKey:@"SortManagerPaths"] objectAtIndex:rowIndex];
	NSString* destination = [cellProperties objectForKey:@"Path"];	

	[[ComponentManager getInteranlComponentNamed:@"FileOperations"]
		moveFile:currentFile
			  to:[EGPath pathWithPath:destination]];	
	
//	id currentFile = [pluginLayer currentFile];
//	[pluginLayer moveFile:currentFile
//					   to:destination];
}

-(IBAction)copyButtonPushed:(id)sender
{
	int rowIndex = [sender selectedRow];
	id cellProperties = [[[NSUserDefaults standardUserDefaults] 
		objectForKey:@"SortManagerPaths"] objectAtIndex:rowIndex];
	NSString* destination = [cellProperties objectForKey:@"Path"];

	[[ComponentManager getInteranlComponentNamed:@"FileOperations"]
		copyFile:currentFile
			  to:[EGPath pathWithPath:destination]];
	
//	[pluginLayer copyFile:[pluginLayer currentFile]
//					   to:destination];
}

-(void)fileSetTo:(EGPath*)newPath
{
	NSNumber* valid;
	[currentFile release];
	currentFile = [newPath retain];
	
	if(newPath)
	{
		[keyValues setValue:newPath forKey:@"CurrentFile"];
		// Assumption: Any path passed in here that's not null is valid.
		valid = [NSNumber numberWithBool:YES];
	}
	else
	{
		[keyValues setValue:@"" forKey:@"CurrentFile"];
		valid = [NSNumber numberWithBool:NO];
	}

	if(![valid isEqual:[keyValues objectForKey:@"ValidDirectory"]])
	{
		[keyValues setValue:valid forKey:@"ValidDirectory"];
	
		// Now force a full redisplay
		if([[tableView window] isVisible])
			[tableView setNeedsDisplay:YES];
	}
}

/////////////////////////////////////////////////// PROTOCOL: CurrentFilePlugin
-(void)activatePluginWithFile:(EGPath*)path inWindow:(NSWindow*)window
					  context:(NSDictionary*)context
{
	[self showWindow:self];	
	[self fileSetTo:path];
}

-(void)currentImageSetTo:(EGPath*)path
{
	[self fileSetTo:path];
}

//////////////////////////////////////////////////////////// NSTable Datasource
- (void) tableView: (NSTableView*) tableView willDisplayCell: (id) cell 
	forTableColumn: (NSTableColumn*) tableColumn row: (int) row 
{ 
	// Manually bind each cell to it's corresponding location
    NSDictionary* filter = [[pathsController arrangedObjects] objectAtIndex:row];
    [cell bind:@"enabled" toObject:filter withKeyPath:@"Path" options:
		[NSDictionary dictionaryWithObjectsAndKeys:@"PathExistsValueTransformer", 
			@"NSValueTransformerName", nil]];
	
	// If the column isn't the final one
	if(![[tableColumn identifier] isEqual:NSLocalizedString(@"Destination", 
		@"Destination Column header (Must be the same as in the NIB!)")])
	{
		[cell bind:@"enabled2" toObject:keyValues withKeyPath:@"ValidDirectory" options:nil];
	}
}

@end
