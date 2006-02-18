/////////////////////////////////////////////////////////////////////////
// File:          $Name$
// Module:        Category responsible for managing the toolbar
// Part of:       VitaminSEE
//
// Revision:      $Revision$
// Last edited:   $Date$
// Author:        $Author$
// Copyright:     (c) 2005 Elliot Glaysher
// Created:       1/30/05
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
// Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, 
// USA.
//
////////////////////////////////////////////////////////////////////////

#import "FavoritesToolbarItem.h"
#import "ToolbarDelegate.h"
#import "ViewIconViewController.h"
#import "NSString+FileTasks.h"
#import "AppKitAdditions.h"
#import "ComponentManager.h"
#import "FavoritesMenuFactory.h"
#import "ApplicationController.h"

// Our Viewer's ID
static NSString* MainViewerWindowToolbarIdentifier = 
	@"Main Viewere Window Toolbar Identifier";

// Our Toolbar items...
static NSString* ZoomInToolbarID = @"Zoom in Toolbar Identifier";
static NSString* ZoomOutToolbarID = @"Zoom out Toolbar Identifier";
static NSString* ZoomToFitToolbarID = @"Zoom to Fit Toolbar Identifier";
static NSString* ActualSizeToolbarID = @"Actual Size Toolbar Identifier";

static NSString* RevealInFinderToolbarID = @"View in Finder Toolbar Identifier";
static NSString* ViewInPreviewToolbarID =@"Reveal in Finder Toolbar Identifier";

static NSString* MoveToTrashID = @"Move Item to Trash Toolbar Identifier";

static NSString* EnclosingFolderID = @"Enclosing Folder Toolbar Identifier";

static NSString* GotoComputerID = @"Goto Computer Toolbar Identifier";
static NSString* GotoPicturesID = @"Goto Pictures Toolbar Identifier";
static NSString* GotoHomeID = @"Goto Home Toolbar Identifier";
static NSString* FavoritesID = @"Favorites Toolbar Identifier";

static NSString* GotoFolderID = @"Goto Folder Toolbar Identifier";

static NSString* NextPictureToolbarID = @"Next Picture Toolbar Identifier";
static NSString* PreviousPictureToolbarID = 
	@"Previous Picture Toolbar Identifier";

/** This instance of the class is created once and is used to validate all
 * toolbars for viewer windows.
 */
static ToolbarDelegate* toolbarDelegateObject = 0;

@implementation ToolbarDelegate

/** Initialize our global instance of ToolbarDelegate.
 */
+(void)initialize
{
	toolbarDelegateObject = [[ToolbarDelegate alloc] init];
}

/** Create a new toolbar object and pass it to the caller.
 */
+(NSToolbar*)buildToolbar {
	// Create the toolbar
	NSToolbar* toolbar = [[[NSToolbar alloc] initWithIdentifier:
		MainViewerWindowToolbarIdentifier] autorelease];
	[toolbar setAllowsUserCustomization:YES];
	[toolbar setAutosavesConfiguration:YES];
	[toolbar setDelegate:toolbarDelegateObject];	
	[toolbar validateVisibleItems];

	return toolbar;
}

// This function hands back NSToolbarItems for various NSString identifiers
- (NSToolbarItem *) toolbar:(NSToolbar *)toolbar
	  itemForItemIdentifier:(NSString *)itemIdent
  willBeInsertedIntoToolbar:(BOOL) willBeInserted
{
	NSToolbarItem* item = [[[NSToolbarItem alloc] 
		initWithItemIdentifier:itemIdent] autorelease];
	
	if([itemIdent isEqual:ZoomInToolbarID])
	{
		[item setLabel:NSLocalizedString(@"Zoom in", @"Toolbar Item")];
		[item setPaletteLabel:NSLocalizedString(@"Zoom in", @"Toolbar Item")];
		[item setToolTip:NSLocalizedString(@"Zoom in", @"Toolbar Item")];
		[item setImage:[NSImage imageNamed:@"ZoomInToolbarImage"]];
		[item setAction:@selector(zoomIn:)];
	}
	else if([itemIdent isEqual:ZoomOutToolbarID])
	{
		[item setLabel:NSLocalizedString(@"Zoom out", @"Toolbar Item")];
		[item setPaletteLabel:NSLocalizedString(@"Zoom out", @"Toolbar Item")];
		[item setToolTip:NSLocalizedString(@"Zoom out", @"Toolbar Item")];
		[item setImage:[NSImage imageNamed:@"ZoomOutToolbarImage"]];
		[item setAction:@selector(zoomOut:)];
	}
	else if([itemIdent isEqual:ZoomToFitToolbarID])
	{
		[item setLabel:NSLocalizedString(@"Zoom to fit", @"Toolbar Item")];
		[item setPaletteLabel:NSLocalizedString(@"Zoom to fit", 
												@"Toolbar Item")];
		[item setToolTip:NSLocalizedString(@"Zoom to fit", @"Toolbar Item")];
		[item setImage:[NSImage imageNamed:@"ZoomToFitToolbarImage"]];
		[item setAction:@selector(zoomToFit:)];
	}
	else if([itemIdent isEqual:ActualSizeToolbarID])
	{
		[item setLabel:NSLocalizedString(@"Actual Size", @"Toolbar Item")];
		[item setPaletteLabel:NSLocalizedString(@"Actual Size", 
												@"Toolbar Item")];
		[item setToolTip:NSLocalizedString(@"Actual Size", @"Toolbar Item")];
		[item setImage:[NSImage imageNamed:@"ActualSizeToolbarImage"]];
		[item setAction:@selector(actualSize:)];	
	}
	else if([itemIdent isEqual:RevealInFinderToolbarID])
	{
		[item setLabel:NSLocalizedString(@"Finder", @"Toolbar Item")];
		[item setPaletteLabel:NSLocalizedString(@"Reveal in Finder",
												@"Toolbar Item")];
		[item setToolTip:NSLocalizedString(@"Reveal in Finder", 
										   @"Toolbar Item")];
		// fixme: This slows stuff down. Perhaps I'd like to not suck?
		[item setImage:[[NSWorkspace sharedWorkspace] 
			iconForApplication:@"Finder"]];
		[item setAction:@selector(revealInFinder:)];
	}
	else if([itemIdent isEqual:ViewInPreviewToolbarID])
	{
		[item setLabel:NSLocalizedString(@"Preview", @"Toolbar Item")];
		[item setPaletteLabel:NSLocalizedString(@"View in Preview", 
												@"Toolbar Item")];
		[item setToolTip:NSLocalizedString(@"View in Preview", 
										   @"Toolbar Item")];
		// fixme: This slows stuff down. Perhaps I'd like to not suck?
		[item setImage:[[NSWorkspace sharedWorkspace] 
			iconForApplication:@"Preview"]];
		[item setAction:@selector(openInPreview:)];		
	}
	else if([itemIdent isEqual:MoveToTrashID])
	{
		[item setLabel:NSLocalizedString(@"Delete", @"Toolbar Item")];
		[item setPaletteLabel:NSLocalizedString(@"Delete", @"Toolbar Item")];
		[item setToolTip:NSLocalizedString(@"Delete", @"Toolbar Item")];
		[item setImage:[NSImage imageNamed:@"ToolbarDeleteIcon"]];
		[item setAction:@selector(moveToTrash:)];				
	}
	else if([itemIdent isEqual:EnclosingFolderID])
	{
		[item setLabel:NSLocalizedString(@"Enclosing", @"Toolbar Item")];
		[item setPaletteLabel:NSLocalizedString(@"Enclosing Folder", @"Toolbar Item")];
		[item setToolTip:NSLocalizedString(@"Enclosing Folder", @"Toolbar Item")];
		[item setImage:[NSImage imageNamed:@"UpArrow"]];
		[item setAction:@selector(goEnclosingFolder:)];						
	}
	else if([itemIdent isEqual:GotoComputerID])
	{
		[item setLabel:NSLocalizedString(@"Computer", @"Toolbar Item")];
		[item setPaletteLabel:NSLocalizedString(@"Computer", @"Toolbar Item")];
		[item setToolTip:NSLocalizedString(@"Computer", @"Toolbar Item")];
		[item setImage:[NSImage imageNamed:@"iMac"]];
		[item setAction:@selector(goToComputer:)];				
	}	
	else if([itemIdent isEqual:GotoHomeID])
	{
		[item setLabel:NSLocalizedString(@"Home", @"Toolbar Item")];
		[item setPaletteLabel:NSLocalizedString(@"Home", @"Toolbar Item")];
		[item setToolTip:NSLocalizedString(@"Home", @"Toolbar Item")];
		[item setImage:[NSImage imageNamed:@"HomeFolderIcon"]];
		[item setAction:@selector(goToHomeDirectory:)];				
	}
	else if([itemIdent isEqual:GotoPicturesID])
	{
		[item setLabel:NSLocalizedString(@"Pictures", @"Toolbar Item")];
		[item setPaletteLabel:NSLocalizedString(@"Pictures", @"Toolbar Item")];
		[item setToolTip:NSLocalizedString(@"Pictures", @"Toolbar Item")];
		[item setImage:[NSImage imageNamed:@"ToolbarPicturesFolderIcon"]];
		[item setAction:@selector(goToPicturesDirectory:)];
	}
	else if([itemIdent isEqual:GotoFolderID])
	{
		[item setLabel:NSLocalizedString(@"Go To...", @"Toolbar Item")];
		[item setPaletteLabel:NSLocalizedString(@"Go To Folder...", @"Toolbar Item")];
		[item setToolTip:NSLocalizedString(@"Go To Folder...", @"Toolbar Item")];
		[item setImage:[NSImage imageNamed:@"goto"]];
		[item setTarget:[ApplicationController controller]];
		[item setAction:@selector(goToFolder:)];
	}
	else if([itemIdent isEqual:FavoritesID])
	{
		// FavoritesToolbarItem is special.
		item = [[[ComponentManager getInteranlComponentNamed:@"FavoritesMenu"] 
			buildToolbarItemWithIdentifier:itemIdent] autorelease];
	}
	else if([itemIdent isEqual:NextPictureToolbarID])
	{
		[item setLabel:NSLocalizedString(@"Next", @"Toolbar Item")];
		[item setPaletteLabel:NSLocalizedString(@"Next", @"Toolbar Item")];
		[item setToolTip:NSLocalizedString(@"Next", @"Toolbar Item")];
		[item setImage:[NSImage imageNamed:@"NextToolbarImage"]];
		[item setAction:@selector(goNextFile:)];
	}
	else if([itemIdent isEqual:PreviousPictureToolbarID])
	{
		[item setLabel:NSLocalizedString(@"Previous", @"Toolbar Item")];
		[item setPaletteLabel:NSLocalizedString(@"Previous", @"Toolbar Item")];
		[item setToolTip:NSLocalizedString(@"Previous", @"Toolbar Item")];
		[item setImage:[NSImage imageNamed:@"PreviousToolbarImage"]];
		[item setAction:@selector(goPreviousFile:)];		
	}	
	else
		item = nil;

	return item;
}

- (NSArray *) toolbarDefaultItemIdentifiers: (NSToolbar *) toolbar
{
	return [NSArray arrayWithObjects:RevealInFinderToolbarID, 
		ViewInPreviewToolbarID, NSToolbarSeparatorItemIdentifier,
		NextPictureToolbarID, PreviousPictureToolbarID,
		NSToolbarSeparatorItemIdentifier, GotoComputerID,
		GotoHomeID, GotoPicturesID, FavoritesID, 
		NSToolbarSeparatorItemIdentifier, NSToolbarFlexibleSpaceItemIdentifier, 
		ZoomInToolbarID, ZoomOutToolbarID, ZoomToFitToolbarID, 
		ActualSizeToolbarID, nil];
}

- (NSArray *) toolbarAllowedItemIdentifiers: (NSToolbar *) toolbar
{
	return [NSArray arrayWithObjects:RevealInFinderToolbarID, 
		ViewInPreviewToolbarID, MoveToTrashID, EnclosingFolderID, 
		GotoComputerID, GotoHomeID, GotoPicturesID,  FavoritesID, GotoFolderID,
		ZoomInToolbarID, ZoomOutToolbarID,
		ZoomToFitToolbarID, ActualSizeToolbarID, NextPictureToolbarID, 
		PreviousPictureToolbarID, NSToolbarSeparatorItemIdentifier,
		NSToolbarSpaceItemIdentifier, NSToolbarFlexibleSpaceItemIdentifier,
		NSToolbarCustomizeToolbarItemIdentifier, nil];
}

@end
