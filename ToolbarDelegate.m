//
//  ToolbarDelegate.m
//  CQView
//
//  Created by Elliot on 1/30/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "ToolbarDelegate.h"

// Our Viewer's ID
static NSString* MainViewerWindowToolbarIdentifier = @"Main Viewere Window Toolbar Identifier";

// Our 
static NSString* ScaleViewToolbarID = @"Scale view control Toolbar Identifier";

@implementation CQViewController (ToolbarDelegate)

-(void)setupToolbar {
	// Create the toolbar
	NSToolbar* toolbar = [[[NSToolbar alloc] initWithIdentifier:MainViewerWindowToolbarIdentifier] autorelease];
	[toolbar setAllowsUserCustomization:YES];
	[toolbar setAutosavesConfiguration:YES];
	[toolbar setDelegate:self];
	
	// Setup the toolbar views to be retained and owned by THIS CONTROLLER. 
	// We do NOT want them to get GCed.
	[scaleView retain];
	[scaleView removeFromSuperview];
	
	[viewerWindow setToolbar:toolbar];
}

// This function hands back NSToolbarItems for various NSString identifiers
- (NSToolbarItem *) toolbar:(NSToolbar *)toolbar
	  itemForItemIdentifier:(NSString *)itemIdent
  willBeInsertedIntoToolbar:(BOOL) willBeInserted
{
//	NSLog(@"toolbar:%@ itemForItemIdentifier:%@", toolbar, itemIdent);
	NSToolbarItem* item = [[[NSToolbarItem alloc] initWithItemIdentifier:itemIdent] autorelease];
	if([itemIdent isEqual:ScaleViewToolbarID])
	{
		[item setLabel:@"Scale"];
		[item setPaletteLabel:@"Scale"];
		[item setToolTip:@"Scale ratio of the image being displayed"];
		[item setView:scaleView];
//		NSLog(@"scaleView: %@", scaleView);
		[item setMinSize:NSMakeSize(NSWidth([scaleView frame]), NSHeight([scaleView frame]))];
		[item setMaxSize:NSMakeSize(NSWidth([scaleView frame]), NSHeight([scaleView frame]))];
		
		// Custom menu for when toolbar item is in text only mode (note that all functionality
		// in this mode is duplicated from Application menu...)
		NSMenu *submenu=[[[NSMenu alloc] init] autorelease];

		// Set to 100%
		NSMenuItem *submenuItem=[[[NSMenuItem alloc] initWithTitle: @"Set scale to 1:1"
															action:@selector(scaleView100Pressed:)
													 keyEquivalent: @""] autorelease];
		[submenu addItem:submenuItem];
		submenuItem=[[[NSMenuItem alloc] initWithTitle: @"Scale proportionally"
												action:@selector(scaleViewPPressed:)
													 keyEquivalent: @""] autorelease];
		[submenu addItem:submenuItem];
		
		NSMenuItem *menuFormRep=[[[NSMenuItem alloc] init] autorelease];
		[submenuItem setTarget:self];
		[menuFormRep setSubmenu:submenu];
		[menuFormRep setTitle:[item label]];
		[item setMenuFormRepresentation:menuFormRep];
	}
	else
		item = nil;

//	NSLog(@"Returning %@", item);
	return item;
}

- (NSArray *) toolbarDefaultItemIdentifiers: (NSToolbar *) toolbar
{
	return [NSArray arrayWithObjects:NSToolbarCustomizeToolbarItemIdentifier,
		NSToolbarFlexibleSpaceItemIdentifier, ScaleViewToolbarID, nil];
}

- (NSArray *) toolbarAllowedItemIdentifiers: (NSToolbar *) toolbar
{
	return [NSArray arrayWithObjects:ScaleViewToolbarID, NSToolbarSeparatorItemIdentifier,
		NSToolbarSpaceItemIdentifier, NSToolbarFlexibleSpaceItemIdentifier,
		NSToolbarCustomizeToolbarItemIdentifier, nil];
}



@end
