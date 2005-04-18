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
// This library is free software; you can redistribute it and/or
// modify it under the terms of the GNU Lesser General Public
// License as published by the Free Software Foundation; either
// version 2.1 of the License, or (at your option) any later version.
//  
// This library is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
// Lesser General Public License for more details.
//  
// You should have received a copy of the GNU Lesser General Public
// License along with this library; if not, write to the Free Software
// Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  
// USA
//
/////////////////////////////////////////////////////////////////////////

#import "SortManagerController.h"
#import "PluginLayer.h"

@implementation SortManagerController

////////////////////////////////////////////////////////// PROTOCOL: PluginBase
-(id)initWithPluginLayer:(PluginLayer*)inPluginLayer;
{
	// Load the nib file
	if(self = [super initWithWindowNibName:@"SortManager"])
	{
		// stuff could go here.
		pluginLayer = inPluginLayer;
		[pluginLayer retain];
	}
	
	return self;
}

-(void)dealloc
{
	[pluginLayer release];
}

-(void)windowDidLoad
{
	[super windowDidLoad];
	
	[self setShouldCascadeWindows:NO];
	[self setWindowFrameAutosaveName:@"sortManagerWindowPosition"];
}

-(IBAction)moveButtonPushed:(id)sender
{
	int rowIndex = [sender selectedRow];
	id cellProperties = [[[NSUserDefaults standardUserDefaults] 
		objectForKey:@"SortManagerPaths"] objectAtIndex:rowIndex];
	NSString* destination = [cellProperties objectForKey:@"Path"];	

	id currentFile = [pluginLayer currentFile];
	[pluginLayer moveFile:currentFile
					   to:destination];
}

-(IBAction)copyButtonPushed:(id)sender
{
	int rowIndex = [sender selectedRow];
	id cellProperties = [[[NSUserDefaults standardUserDefaults] 
		objectForKey:@"SortManagerPaths"] objectAtIndex:rowIndex];
	NSString* destination = [cellProperties objectForKey:@"Path"];

	[pluginLayer copyFile:[pluginLayer currentFile]
					   to:destination];
}

-(void)fileSetTo:(NSString*)newPath
{
	// Ignore. We just use the "this file" commands in 
}

/////////////////////////////////////////////////// PROTOCOL: CurrentFilePlugin
-(NSString*)name
{
	return @"Sort Manager";
}

-(void)activate
{
	[self showWindow:self];
}

-(NSArray*)contextMenuItems
{
	return nil;
}

//////////////////////////////////////////////////////////// NSTable Datasource
- (void) tableView: (NSTableView*) tableView willDisplayCell: (id) cell 
	forTableColumn: (NSTableColumn*) tableColumn row: (int) row 
{ 
	// Manually bind each cell to it's corresponding location
    NSDictionary* filter = [[pathsController arrangedObjects] objectAtIndex:row];
    [cell bind:@"enabled" toObject:filter withKeyPath:@"Path" options:
		[NSDictionary dictionaryWithObjectsAndKeys:@"PathExistsValueTransformer", @"NSValueTransformerName", nil]
			];
}

//////////// 
-(NSUndoManager*)windowWillReturnUndoManager:(id)window
{
	return [pluginLayer undoManager];
}


@end
