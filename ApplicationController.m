/////////////////////////////////////////////////////////////////////////
// File:          $Name$
// Module:        Main Controller Class
// Part of:       VitaminSEE
//
// ID:            $Id: ApplicationController.m 123 2005-04-18 00:21:02Z elliot $
// Revision:      $Revision: 248 $
// Last edited:   $Date: 2005-07-13 20:26:59 -0500 (Wed, 13 Jul 2005) $
// Author:        $Author: elliot $
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
// Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
//
////////////////////////////////////////////////////////////////////////

#include <sys/stat.h>


//#import "FSNodeInfo.h"
//#import "FSBrowserCell.h"

//#import "VitaminSEEPicture.h"
#import "ApplicationController.h"
#import "ViewerDocument.h"
#import "VitaminSEEWindowController.h"
#import "GotoFolderSheetController.h"
#import "GotoFolderWindowController.h"
#import "ComponentManager.h"
#import "FavoritesMenuDelegate.h"
#import "RBSplitView.h"
#import "RBSplitSubview.h"
#import "FavoritesMenuFactory.h"
#import "NSString+FileTasks.h"

#import "EGPath.h"

@implementation ApplicationController

///////// TEST PLAN

/*
 * Moving a file into a directory where that file already exists.
 */

////////////////////////////////////////////////// WHERE TO GO FROM HERE...

// For Version 0.7
// * Delete key in sort manager preferences should do something. + UNDO!!!!
// * Automator actions:
//   * Set wallpaper to selection
// * Fullscreen + Slideshow
// * Have thumbnails scale down if right side is shrunk (rework NSBrowserCell
//   subclass to use NSImageCell?)
// * Undo on delete. (0.7 by absolute latest!)
//   * Requires figuring out how the Mac trash system works; 
//     NSWorkspaceRecycleOperation isn't behaving how the Finder behaves. Maybe
//     the answer is in Carbon?
// * Thumbnail options.

// For Version 0.8
// * Transparent archive support
// * Fit height/width
// * DnD on the ViewIconViewController
// * Mouse-wheel scrolling...
//   * Requires next/previous 
// * UNIT TESTING!

// For Version 0.9
// * Create an image database feature
// * Automator action: Find images
// * Add metadata for PNG and GIF
// * 2 million% more complete metadata! Exif panel! IPTC panel!

// For Version 0.9
// * Image search
// * Duplicate/similarity search
// * Finder notifications (a.k.a. don't make the user refresh)

// For Version 1.0
// ??????

// For Version 0.6.2
// * Cache control. How large?
// * Check for file on remote volume.

// KNOWN ISSUES:
// * GIF animation speed.
// * (Some) Animated GIFs broken in Tiger?
// * Very rare Kotoeri crash at startup. No clue what's causing it.
// * Disable labels in KeywordManager (wishlist)

/* Okay, refactoring responsibilities:
  * ApplicationController is responsible for ONLY:
    * Displaying the image
    * Knowing the name of the current image
    * Responding to UI events
  * FileDisplay
    * Knows about the current directory. Draws stuff. Et cetera.
*/

/**
  Non-required improvements that would be a good idea:
  * Fit to height/Fit to width
  */

/////////////////////////////////////////////////////////// POST CONTEST GOALS:

/* SECOND MILESTONE GOALS
 * Image search (Must be a loadable bundle!)
 * Duplicate search (Must be a loadable bundle!)
 * Integrate into the [Computer name]/[Macintosh HD]/.../ hiearachy...
 * Transparent Zip/Rar support (Must be a loadable bundle!)
 * Respond to finder notifications!
 * Draging of the picture
 * * See "openHandCursor" and "closedHandCursor"
 * Fullscreen mode.
 * Make Go to folder modal when main window isn't open.
 * GIF/PNG keywords and comments.    
 * JPEG comments
 * Change arrow key behaviour - scroll around in image if possible in NSScrollView
   and switch images
   * Julius says see "CDisplay" (Comics Viewer)
*/

+ (void)initialize 
{
	// Set up our custom NSValueTransformers
//	[NSValueTransformer setValueTransformer:[[[ImmutableToMutableTransformer 
//		alloc] init] autorelease] forName:@"ImmutableToMutableTransformer"];
//	[NSValueTransformer setValueTransformer:[[[PathExistsValueTransformer alloc]
//		init] autorelease] forName:@"PathExistsValueTransformer"];
//	[NSValueTransformer setValueTransformer:[[[FullDisplayNameValueTransformer
//		alloc] init] autorelease] forName:@"FullDisplayNameValueTransformer"];
	
	// Test to see if the user is a rebel and deleted the Pictures folder
	NSString* picturesFolder = [NSHomeDirectory() stringByAppendingPathComponent:@"Pictures"];
	NSFileManager* fileManager = [NSFileManager defaultManager];
	BOOL hasPictures, picturesFolderExists, picturesFolderIsDir;
	picturesFolderExists = [fileManager fileExistsAtPath:picturesFolder 
											 isDirectory:&picturesFolderIsDir];
	hasPictures = picturesFolderExists && picturesFolderIsDir;
	
	// Set up this application's default preferences	
    NSMutableDictionary *defaultPrefs = [NSMutableDictionary dictionary];

	// Set the default path.
	if(hasPictures)
		[defaultPrefs setObject:picturesFolder forKey:@"DefaultStartupPath"];
	else
		[defaultPrefs setObject:NSHomeDirectory() forKey:@"DefaultStartupPath"];
    
	// General preferences
	[defaultPrefs setObject:[NSNumber numberWithInt:3] forKey:@"SmoothingTag"];
	[defaultPrefs setObject:[NSNumber numberWithBool:YES] forKey:@"DisplayThumbnails"];
	[defaultPrefs setObject:[NSNumber numberWithBool:YES] forKey:@"GenerateThumbnails"];
	[defaultPrefs setObject:[NSNumber numberWithBool:YES] forKey:@"SaveThumbnails"];
	[defaultPrefs setObject:[NSNumber numberWithBool:NO] forKey:@"GenerateThumbnailsInArchives"];
	[defaultPrefs setObject:[NSNumber numberWithBool:YES] forKey:@"PreloadImages"];
	[defaultPrefs setObject:[NSNumber numberWithBool:NO] forKey:@"ShowHiddenFiles"];

	// Keyword preferences
//	KeywordNode* node = [[[KeywordNode alloc] initWithParent:nil keyword:@"Keywords"] autorelease];
//	NSData* emptyKeywordNode = [NSKeyedArchiver archivedDataWithRootObject:node];
//	[defaultPrefs setObject:emptyKeywordNode forKey:@"KeywordTree"];
	
	// Default sort manager array
	NSArray* sortManagerPaths;
	NSString* firstPath;
	if(hasPictures)
		firstPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Pictures"];
	else
		firstPath = NSHomeDirectory();

	sortManagerPaths = [NSArray arrayWithObjects:
		[NSDictionary dictionaryWithObjectsAndKeys:[fileManager displayNameAtPath:firstPath], @"Name",
			firstPath, @"Path", nil], nil];
	
	[defaultPrefs setObject:sortManagerPaths forKey:@"SortManagerPaths"];
	[defaultPrefs setObject:[NSNumber numberWithBool:YES] forKey:@"SortManagerInContextMenu"];
	
	[[NSUserDefaults standardUserDefaults] registerDefaults: defaultPrefs];
}

static ApplicationController* appControl;
+(ApplicationController*)controller
{
	return appControl;
}

-(NSNumber*)getNextAvailableID
{
	NSNumber* docid = [NSNumber numberWithInt:nextDocumentID];
	nextDocumentID++;
	return docid;
}

- (void)awakeFromNib
{
	nextDocumentID = 0;
	appControl = self;
//	NSLog(@"-[ApplicationController awakeFromNib]");
	// Set our plugins to nil
	loadedBasePlugins = [[NSMutableDictionary alloc] init];
	loadedViewPlugins = [[NSMutableDictionary alloc] init];
	loadedCurrentFilePlugins = [[NSMutableDictionary alloc] init];	
	
	pictureViewers = [[NSMutableArray alloc] init];
	
	setPathForFirstTime = NO;
}

-(void)dealloc
{
	[super dealloc];
}

////////////////////////////////////////////////////////// APPLICATION DELEGATE

// This initialization can safely be delayed until after the main window has
// been shown.
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
//	NSLog(@"-[ApplicationController applicationDidFinishLaunching]");

	[self newWindow:self];
}

-(IBAction)newWindow:(id)sender
{
	[[ViewerDocument alloc] initWithPath:
		[EGPath pathWithPath:[@"~/Pictures" stringByExpandingTildeInPath]]];
}

//
-(BOOL)validateMenuItem:(NSMenuItem *)theMenuItem
{
	BOOL enable = [self respondsToSelector:[theMenuItem action]];
	SEL action = [theMenuItem action];
	
	if (action == @selector(fakeFavoritesMenuSelector:))
	{
		[theMenuItem setAction:nil];
		
		// Set up the Favorites Menu
		NSMenu* favoritesMenu = [[[NSMenu alloc] init] autorelease];
		favoritesMenuDelegate = [[ComponentManager getInteranlComponentNamed:@"FavoritesMenu"] 
			buildMenuDelegate];
		[favoritesMenu setDelegate:favoritesMenuDelegate];
		[theMenuItem setSubmenu:favoritesMenu];		
	}	
	else if (action == @selector(goToComputer:))
	{
		// Set the icon if we don't have one yet.
		if(![theMenuItem image])
		{
			NSImage* img = [[NSImage imageNamed:@"iMac"] copy];
			[img setScalesWhenResized:YES];
			[img setSize:NSMakeSize(16, 16)];
			[theMenuItem setImage:img];
			[img release];
		}
	}	
	else if (action == @selector(goToHomeDirectory:))
	{
		// Set the icon if we don't have one yet.
		if(![theMenuItem image])
		{
			NSImage* img = [[NSWorkspace sharedWorkspace] iconForFile:NSHomeDirectory()];
			[img setSize:NSMakeSize(16, 16)];
			[theMenuItem setImage:img];
		}
	}
	else if (action == @selector(goToPicturesDirectory:))
	{
		enable = [[NSHomeDirectory() stringByAppendingPathComponent:@"Pictures"] isDir];
		
		// Set the icon if we haven't done so yet.
		if(![theMenuItem image])
		{
			NSImage* img;
			if(enable)
			{
				img = [[[NSImage imageNamed:@"ToolbarPicturesFolderIcon"] copy] autorelease];
				[img setScalesWhenResized:YES];
				[img setSize:NSMakeSize(16, 16)];
			}
			else
				img = [[NSImage alloc] initWithSize:NSMakeSize(16,16)];
			
			[theMenuItem setImage:img];
		}
	}
	
	return enable;
}


///////////////////////////////////////////////////////////////// GO MENU ITEMS

/** Action that will set the directory of the current window to the Computer
 * (if the current window's FileList supports setting a directory), or opens
 * a new window to the location Computer if no windows are open.
 *
 * @see -goToDirectory
 */
-(IBAction)goToComputer:(id)sender
{
	[self goToDirectory:[EGPath root]];
}

//-----------------------------------------------------------------------------

/** Action that will set the directory of the current window to the users' home
 * directory (if the current window's FileList supports setting a directory), 
 * or opens a new window to the location Computer if no windows are open.
 *
 * @see -goToDirectory
 */
-(IBAction)goToHomeDirectory:(id)sender
{
	[self goToDirectory:[EGPath pathWithPath:[@"~/" stringByExpandingTildeInPath]]];
}

//-----------------------------------------------------------------------------

/** Action that will set the directory of the current window to the users'
 * Pictures directory (if the current window's FileList supports setting a
 * directory), or opens a new window to the location Computer if no windows are
 * open.
 *
 * @see -goToDirectory
 */
-(IBAction)goToPicturesDirectory:(id)sender
{
	[self goToDirectory:[EGPath pathWithPath:[@"~/Pictures" stringByExpandingTildeInPath]]];
}

//-----------------------------------------------------------------------------

/** 
 *
 */
-(IBAction)goToFolder:(id)sender
{
	if([NSApp mainWindow]) 
	{
		id gotoDelegate = [[ComponentManager getInteranlComponentNamed:@"GotoFolderSheet"] build];
		NSWindow* mainWindow = [NSApp mainWindow];
		NSWindowController* controller = [mainWindow windowController];
		ViewerDocument* document = [controller document];
		
		// Start 
		NSLog(@"Goto delegate: %@", gotoDelegate);
		
		[gotoDelegate showSheet:mainWindow
				   initialValue:@"~/Pictures"
						 target:document
					   selector:@selector(setDirectoryFromRawPath:)];
	}
	else
	{
		id gotoDelegate = [[ComponentManager getInteranlComponentNamed:@"GotoFolderWindow"] build];
		
		[gotoDelegate showModalWindowWithInitialValue:@"~/Pictures"
											   target:self
											 selector:@selector(goToDirectory:)];
	}
}

//-----------------------------------------------------------------------------

/** Sets the current directory of the mainWindow, or create a new window with
 * the directory.
 */
-(void)goToDirectory:(EGPath*)path
{
	NSWindow* mainWindow = [NSApp mainWindow];
	NSWindowController* controller = [mainWindow windowController];
	ViewerDocument* document = [controller document];
	
	if(mainWindow && controller && document) 
	{
		// Tell it to set the directory
		[document setDirectory:path];
	}
	else 
	{
		// We have to make a new window to set the directory on it!
		[[ViewerDocument alloc] initWithPath:path];
	}
}

//-----------------------------------------------------------------------------

/** Selector that doesn't do anything. It's detected at runtime through
 * -validateMenuItem:, and a submenu is generated.
 */
-(IBAction)fakeFavoritesMenuSelector:(id)sender
{
	
}

@end
