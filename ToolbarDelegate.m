//
//  ToolbarDelegate.m
//  CQView
//
//  Created by Elliot on 1/30/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

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

@implementation VitaminSEEController (ToolbarDelegate)

-(void)setupToolbar {
	// Create the toolbar
	NSToolbar* toolbar = [[[NSToolbar alloc] initWithIdentifier:MainViewerWindowToolbarIdentifier] autorelease];
	[toolbar setAllowsUserCustomization:YES];
	[toolbar setAutosavesConfiguration:YES];
	[toolbar setDelegate:self];	
	
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
		[item setLabel:@"Zoom in"];
		[item setPaletteLabel:@"Zoom in"];
		[item setToolTip:@"Zoom in"];
		[item setImage:[NSImage imageNamed:@"ZoomInToolbarImage"]];
		[item setTarget:self];
		[item setAction:@selector(zoomIn:)];
	}
	else if([itemIdent isEqual:ZoomOutToolbarID])
	{
		[item setLabel:@"Zoom out"];
		[item setPaletteLabel:@"Zoom out"];
		[item setToolTip:@"Zoom out"];
		[item setImage:[NSImage imageNamed:@"ZoomOutToolbarImage"]];
		[item setTarget:self];
		[item setAction:@selector(zoomOut:)];
	}
	else if([itemIdent isEqual:ZoomToFitToolbarID])
	{
		[item setLabel:@"Zoom to fit"];
		[item setPaletteLabel:@"Zoom to fit"];
		[item setToolTip:@"Zoom to fit"];
		[item setImage:[NSImage imageNamed:@"ZoomToFitToolbarImage"]];
		[item setTarget:self];
		[item setAction:@selector(zoomToFit:)];
	}
	else if([itemIdent isEqual:ActualSizeToolbarID])
	{
		[item setLabel:@"Actual Size"];
		[item setPaletteLabel:@"Actual Size"];
		[item setToolTip:@"Actual Size"];
		[item setImage:[NSImage imageNamed:@"ActualSizeToolbarImage"]];
		[item setTarget:self];
		[item setAction:@selector(actualSize:)];		
	}
	else if([itemIdent isEqual:RevealInFinderToolbarID])
	{
		[item setLabel:@"Finder"];
		[item setPaletteLabel:@"Reveal in Finder"];
		[item setToolTip:@"Reveal in Finder"];
		[item setImage:[[NSWorkspace sharedWorkspace] iconForApplication:@"Finder"]];
		[item setTarget:self];
		[item setAction:@selector(revealInFinder:)];
	}
	else if([itemIdent isEqual:ViewInPreviewToolbarID])
	{
		[item setLabel:@"Preview"];
		[item setPaletteLabel:@"View in Preview"];
		[item setToolTip:@"View in Preview"];
		[item setImage:[[NSWorkspace sharedWorkspace] iconForApplication:@"Preview"]];
		[item setTarget:self];
		[item setAction:@selector(viewInPreview:)];		
	}
	else if([itemIdent isEqual:MoveToTrashID])
	{
		[item setLabel:@"Delete"];
		[item setPaletteLabel:@"Delete"];
		[item setToolTip:@"Delete"];
		[item setImage:[NSImage imageNamed:@"ToolbarDeleteIcon"]];
		[item setTarget:self];
		[item setAction:@selector(deleteFileClicked:)];				
	}
	else if([itemIdent isEqual:GotoHomeID])
	{
		[item setLabel:@"Home"];
		[item setPaletteLabel:@"Home"];
		[item setToolTip:@"Home"];
		[item setImage:[NSImage imageNamed:@"HomeFolderIcon"]];
		[item setTarget:self];
		[item setAction:@selector(goToHomeFolder:)];				
	}
	else if([itemIdent isEqual:GotoPicturesID])
	{
		[item setLabel:@"Pictures"];
		[item setPaletteLabel:@"Pictures"];
		[item setToolTip:@"Pictures"];
		[item setImage:[NSImage imageNamed:@"ToolbarPicturesFolderIcon"]];
		[item setTarget:self];
		[item setAction:@selector(goToPicturesFolder:)];
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
		MoveToTrashID, GotoPicturesID, GotoHomeID, ZoomInToolbarID, ZoomOutToolbarID,
		ZoomToFitToolbarID, ActualSizeToolbarID, NSToolbarSeparatorItemIdentifier,
		NSToolbarSpaceItemIdentifier, NSToolbarFlexibleSpaceItemIdentifier,
		NSToolbarCustomizeToolbarItemIdentifier, nil];
}

-(BOOL)validateToolbarItem:(NSToolbarItem*)toolbarItem
{
    BOOL enable = NO;
	NSString* identifier = [toolbarItem itemIdentifier];

	if([identifier isEqual:RevealInFinderToolbarID])
	{
		enable = [viewAsIconsController canDelete];
	}
	else if([identifier isEqual:MoveToTrashID])
	{
		enable = [viewAsIconsController canDelete];
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
    } else if ([identifier isEqual:GotoPicturesID] ||
			   [identifier isEqual:GotoHomeID])
	{
        // always enable print for this window
        enable = YES;
    }
	
    return enable;	
}


@end
