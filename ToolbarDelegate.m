//
//  ToolbarDelegate.m
//  CQView
//
//  Created by Elliot on 1/30/05.
//  Copyright 2005 Elliot Glaysher. All rights reserved.
//

#import "FavoritesToolbarItem.h"
#import "ToolbarDelegate.h"
#import "ViewIconViewController.h"
#import "NSString+FileTasks.h"
#import "AppKitAdditions.h"

// Our Viewer's ID
static NSString* MainViewerWindowToolbarIdentifier = @"Main Viewere Window Toolbar Identifier";

// Our Toolbar items...
static NSString* ZoomInToolbarID = @"Zoom in Toolbar Identifier";
static NSString* ZoomOutToolbarID = @"Zoom out Toolbar Identifier";
static NSString* ZoomToFitToolbarID = @"Zoom to Fit Toolbar Identifier";
static NSString* ActualSizeToolbarID = @"Actual Size Toolbar Identifier";

static NSString* RevealInFinderToolbarID = @"View in Finder Toolbar Identifier";
static NSString* ViewInPreviewToolbarID = @"Reveal in Finder Toolbar Identifier";

static NSString* MoveToTrashID = @"Move Item to Trash Toolbar Identifier";

static NSString* GotoPicturesID = @"Goto Pictures Toolbar Identifier";
static NSString* GotoHomeID = @"Goto Home Toolbar Identifier";

static NSString* FavoritesID = @"Favorites Toolbar Identifier";

@implementation VitaminSEEController (ToolbarDelegate)

-(void)setupToolbar {
	// Create the toolbar
	NSToolbar* toolbar = [[[NSToolbar alloc] initWithIdentifier:MainViewerWindowToolbarIdentifier] autorelease];
	[toolbar setAllowsUserCustomization:YES];
	[toolbar setAutosavesConfiguration:YES];
	[toolbar setDelegate:self];	
	[toolbar validateVisibleItems];
	
	[viewerWindow setToolbar:toolbar];
}

// This function hands back NSToolbarItems for various NSString identifiers
- (NSToolbarItem *) toolbar:(NSToolbar *)toolbar
	  itemForItemIdentifier:(NSString *)itemIdent
  willBeInsertedIntoToolbar:(BOOL) willBeInserted
{
	NSToolbarItem* item = [[[NSToolbarItem alloc] initWithItemIdentifier:itemIdent] autorelease];
	if([itemIdent isEqual:ZoomInToolbarID])
	{
		[item setLabel:NSLocalizedString(@"Zoom in", @"Toolbar Item")];
		[item setPaletteLabel:NSLocalizedString(@"Zoom in", @"Toolbar Item")];
		[item setToolTip:NSLocalizedString(@"Zoom in", @"Toolbar Item")];
		[item setImage:[NSImage imageNamed:@"ZoomInToolbarImage"]];
		[item setTarget:self];
		[item setAction:@selector(zoomIn:)];
	}
	else if([itemIdent isEqual:ZoomOutToolbarID])
	{
		[item setLabel:NSLocalizedString(@"Zoom out", @"Toolbar Item")];
		[item setPaletteLabel:NSLocalizedString(@"Zoom out", @"Toolbar Item")];
		[item setToolTip:NSLocalizedString(@"Zoom out", @"Toolbar Item")];
		[item setImage:[NSImage imageNamed:@"ZoomOutToolbarImage"]];
		[item setTarget:self];
		[item setAction:@selector(zoomOut:)];
	}
	else if([itemIdent isEqual:ZoomToFitToolbarID])
	{
		[item setLabel:NSLocalizedString(@"Zoom to fit", @"Toolbar Item")];
		[item setPaletteLabel:NSLocalizedString(@"Zoom to fit", @"Toolbar Item")];
		[item setToolTip:NSLocalizedString(@"Zoom to fit", @"Toolbar Item")];
		[item setImage:[NSImage imageNamed:@"ZoomToFitToolbarImage"]];
		[item setTarget:self];
		[item setAction:@selector(zoomToFit:)];
	}
	else if([itemIdent isEqual:ActualSizeToolbarID])
	{
		[item setLabel:NSLocalizedString(@"Actual Size", @"Toolbar Item")];
		[item setPaletteLabel:NSLocalizedString(@"Actual Size", @"Toolbar Item")];
		[item setToolTip:NSLocalizedString(@"Actual Size", @"Toolbar Item")];
		[item setImage:[NSImage imageNamed:@"ActualSizeToolbarImage"]];
		[item setTarget:self];
		[item setAction:@selector(actualSize:)];		
	}
	else if([itemIdent isEqual:RevealInFinderToolbarID])
	{
		[item setLabel:NSLocalizedString(@"Finder", @"Toolbar Item")];
		[item setPaletteLabel:NSLocalizedString(@"Reveal in Finder", @"Toolbar Item")];
		[item setToolTip:NSLocalizedString(@"Reveal in Finder", @"Toolbar Item")];
		// fixme: This slows stuff down. Perhaps I'd like to not suck?
		[item setImage:[[NSWorkspace sharedWorkspace] iconForApplication:@"Finder"]];
		[item setTarget:self];
		[item setAction:@selector(revealInFinder:)];
	}
	else if([itemIdent isEqual:ViewInPreviewToolbarID])
	{
		[item setLabel:NSLocalizedString(@"Preview", @"Toolbar Item")];
		[item setPaletteLabel:NSLocalizedString(@"View in Preview", @"Toolbar Item")];
		[item setToolTip:NSLocalizedString(@"View in Preview", @"Toolbar Item")];
		// fixme: This slows stuff down. Perhaps I'd like to not suck?
		[item setImage:[[NSWorkspace sharedWorkspace] iconForApplication:@"Preview"]];
		[item setTarget:self];
		[item setAction:@selector(viewInPreview:)];		
	}
	else if([itemIdent isEqual:MoveToTrashID])
	{
		[item setLabel:NSLocalizedString(@"Delete", @"Toolbar Item")];
		[item setPaletteLabel:NSLocalizedString(@"Delete", @"Toolbar Item")];
		[item setToolTip:NSLocalizedString(@"Delete", @"Toolbar Item")];
		[item setImage:[NSImage imageNamed:@"ToolbarDeleteIcon"]];
		[item setTarget:self];
		[item setAction:@selector(deleteFileClicked:)];				
	}
	else if([itemIdent isEqual:GotoHomeID])
	{
		[item setLabel:NSLocalizedString(@"Home", @"Toolbar Item")];
		[item setPaletteLabel:NSLocalizedString(@"Home", @"Toolbar Item")];
		[item setToolTip:NSLocalizedString(@"Home", @"Toolbar Item")];
		[item setImage:[NSImage imageNamed:@"HomeFolderIcon"]];
		[item setTarget:self];
		[item setAction:@selector(goToHomeFolder:)];				
	}
	else if([itemIdent isEqual:GotoPicturesID])
	{
		[item setLabel:NSLocalizedString(@"Pictures", @"Toolbar Item")];
		[item setPaletteLabel:NSLocalizedString(@"Pictures", @"Toolbar Item")];
		[item setToolTip:NSLocalizedString(@"Pictures", @"Toolbar Item")];
		[item setImage:[NSImage imageNamed:@"ToolbarPicturesFolderIcon"]];
		[item setTarget:self];
		[item setAction:@selector(goToPicturesFolder:)];
	}
	else if([itemIdent isEqual:FavoritesID])
	{
		// FavoritesToolbarItem is special.
		item = [[[FavoritesToolbarItem alloc] initWithItemIdentifier:itemIdent
														  controller:self] autorelease];
	}
	else
		item = nil;

	return item;
}

- (NSArray *) toolbarDefaultItemIdentifiers: (NSToolbar *) toolbar
{
	return [NSArray arrayWithObjects:RevealInFinderToolbarID, 
		ViewInPreviewToolbarID, NSToolbarSeparatorItemIdentifier,
		NSToolbarFlexibleSpaceItemIdentifier, 
		ZoomInToolbarID, ZoomOutToolbarID, ZoomToFitToolbarID, 
		ActualSizeToolbarID, nil];
}

- (NSArray *) toolbarAllowedItemIdentifiers: (NSToolbar *) toolbar
{
	return [NSArray arrayWithObjects:RevealInFinderToolbarID, ViewInPreviewToolbarID, 
		MoveToTrashID, GotoPicturesID, GotoHomeID, FavoritesID, ZoomInToolbarID, ZoomOutToolbarID,
		ZoomToFitToolbarID, ActualSizeToolbarID, NSToolbarSeparatorItemIdentifier,
		NSToolbarSpaceItemIdentifier, NSToolbarFlexibleSpaceItemIdentifier,
		NSToolbarCustomizeToolbarItemIdentifier, nil];
}

-(BOOL)validateToolbarItem:(NSToolbarItem*)toolbarItem
{
    BOOL enable = NO;
	NSString* identifier = [toolbarItem itemIdentifier];
//	NSLog(@"Validating %@", identifier);

	if([identifier isEqual:RevealInFinderToolbarID])
	{
		enable = [[viewAsIconsController selectedFiles] count];
	}
	else if([identifier isEqual:MoveToTrashID])
	{
		enable = [[viewAsIconsController selectedFiles] count];
	}
	else if ([identifier isEqual:ActualSizeToolbarID])
	{
		enable = [currentImageFile isImage] && !(scaleProportionally && 
			scaleRatio == 1.0);
	}
	else if ([identifier isEqual:ZoomToFitToolbarID])
	{
		enable = [currentImageFile isImage] && scaleProportionally; // && scaleRatio == 1.0;
	}
    else if ([identifier isEqual:ZoomInToolbarID] || 
			 [identifier isEqual:ZoomOutToolbarID] ||
			 [identifier isEqual:ViewInPreviewToolbarID])
	{
		// We can only do these actions if the file is an image.
        enable = [currentImageFile isImage];
    }
	else if ([identifier isEqual:GotoPicturesID])
	{
		// Only enable the Pictures item if "~/Pictures" exists
		enable = [[NSHomeDirectory() stringByAppendingPathComponent:@"Pictures"] isDir];
	}
	else if ([identifier isEqual:GotoHomeID])
	{
		// Always show home. If the user has deleted his
        enable = YES;
    }
	
    return enable;	
}


@end
