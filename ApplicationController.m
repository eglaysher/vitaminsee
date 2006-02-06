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

#import "ImmutableToMutableTransformer.h"
#import "PathExistsValueTransformer.h"
#import "FullDisplayNameValueTransformer.h"

#import "SS_PrefsController.h"
#import "SSPrefsControllerFactory.h"
#import "ViewMenuDelegate.h"
#import "ToolMenuDelegate.h"

#import "EGPath.h"
#import "HigherOrderMessaging.h"
#import "CurrentFilePlugin.h"

@implementation ApplicationController

///////// TEST PLAN

/*
 * Moving a file into a directory where that file already exists.
 */

////////////////////////////////////////////////// WHERE TO GO FROM HERE...

// Required tasks:
// * Make the FileList use a UKKqueue instance to monitor the current directory;
//   makes stupid, hacky old file management code go away, and make the FileList
//   more self contained.
// * Integrate preferences
// * SPEED UP SORT MANAGER AND FILE OPERATIONS!

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
	[NSValueTransformer setValueTransformer:[[[ImmutableToMutableTransformer 
		alloc] init] autorelease] forName:@"ImmutableToMutableTransformer"];
	[NSValueTransformer setValueTransformer:[[[PathExistsValueTransformer alloc]
		init] autorelease] forName:@"PathExistsValueTransformer"];
	[NSValueTransformer setValueTransformer:[[[FullDisplayNameValueTransformer
		alloc] init] autorelease] forName:@"FullDisplayNameValueTransformer"];
	
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

	// Set our plugins to nil
	loadedBasePlugins = [[NSMutableDictionary alloc] init];
	loadedViewPlugins = [[NSMutableDictionary alloc] init];
	loadedCurrentFilePlugins = [[NSMutableDictionary alloc] init];	
	
	pictureViewers = [[NSMutableArray alloc] init];
	
	setPathForFirstTime = NO;
	loadedOpenWithMenu = NO;
	
	// Set up our view menu delegate. This is important so plugins work.
	NSMenu* mainMenu = [NSApp mainMenu];
	NSMenu* viewMenu = [[mainMenu itemAtIndex:3] submenu];
//	NSMenu* toolMenu = [[mainMenu itemAtIndex:4] submenu];
	NSMenu* windowMenu = [[mainMenu itemAtIndex:5] submenu];
	[viewMenu setDelegate:[[ViewMenuDelegate alloc] init]];
//	[toolMenu setDelegate:[[ToolMenuDelegate alloc] init]];
	
	// Add all the currentfileplugins to the Windows menu. Do it like this 
	// instead of a delegate so we don't screw everything up with the
	// NOTE: Check to see if a NSMenu delegate screws things up later.
	NSArray* currentViews = [ComponentManager getCurrentFilePluginsInViewMenu];
	NSEnumerator* e = [currentViews reverseObjectEnumerator];
	id obj;
	while(obj = [e nextObject]) 
	{
		NSMenuItem* item = [[NSMenuItem alloc] init];
		[item setTitle:[obj objectForKey:@"Menu Name"]];
		[item setAction:@selector(sendPluginActivationSignal:)];
		[item setTarget:self];
		[item setRepresentedObject:obj];
		[windowMenu insertItem:item atIndex:3];
		[item release];
	}
}

//-----------------------------------------------------------------------------

-(void)dealloc
{
	[super dealloc];
}

////////////////////////////////////////////////////////// APPLICATION DELEGATE

/** Handle the opening of files by double-clicks from the Finder and drags to
 * the dock icon.
 */
-(BOOL)application:(NSApplication*)theApplication openFile:(NSString*)filename
{
	if([filename isDir]) 
	{
		[[ViewerDocument alloc] initWithPath:[EGPath pathWithPath:filename]];
		return YES;
	}
	else if([filename isImage])
	{
		id doc = [[ViewerDocument alloc] initWithPath:[EGPath pathWithPath:
			[filename stringByDeletingLastPathComponent]]];
		[doc focusOnFile:[EGPath pathWithPath:filename]];
		return YES;
	}

	AlertSoundPlay();
	return NO;
}

//-----------------------------------------------------------------------------

/** This method gets called when there are no documents open, but one needs to
 * be created. It just calls -newWindow:.
 */
- (BOOL)applicationOpenUntitledFile:(NSApplication *)theApplication
{
	[self newWindow:self];
	return YES;
}

//-----------------------------------------------------------------------------

/** Opens up a new window to the startup folder.
 */
-(IBAction)newWindow:(id)sender
{
	NSString* defaultFolder = [[NSUserDefaults standardUserDefaults] 
		objectForKey:@"DefaultStartupPath"];
	[[ViewerDocument alloc] initWithPath:
		[EGPath pathWithPath:[defaultFolder stringByExpandingTildeInPath]]];
}

//-----------------------------------------------------------------------------

/** Validates a menu item.
 */
-(BOOL)validateMenuItem:(NSMenuItem *)theMenuItem
{
	BOOL enable = [self respondsToSelector:[theMenuItem action]];
	SEL action = [theMenuItem action];
	
	if(action == @selector(fakeOpenWithMenuSelector:))
		enable = [self validateOpenWithMenuItem:theMenuItem];
	else if (action == @selector(fakeFavoritesMenuSelector:))
		enable = [self validateFavoritesMenuItem:theMenuItem];
	else if (action == @selector(goToComputer:))
		enable = [self validateGoToComputerMenuItem:theMenuItem];
	else if (action == @selector(goToHomeDirectory:))
		enable = [self validateGoToHomeDirectoryMenuItem:theMenuItem];
	else if (action == @selector(goToPicturesDirectory:))
		enable = [self validateGoToPicturesDirectoryMenuItem:theMenuItem];
	
	return enable;
}

//-----------------------------------------------------------------------------

/** Validates the Open With... Menu Item. Returns whether it should be enabled.
 */
-(BOOL)validateOpenWithMenuItem:(NSMenuItem*)item
{
	BOOL enable = [self currentFile] && ![[self currentFile] isDirectory];
	
	if(![item submenu] && !enable)
	{
		// Set a false menu
		NSMenu* openWithMenu = [[[NSMenu alloc] init] autorelease];
		[item setSubmenu:openWithMenu];
	}
	else if(!loadedOpenWithMenu && enable)
	{
		// Set up the real Open with Menu
		NSMenu* openWithMenu = [[[NSMenu alloc] init] autorelease];
		id openWithMenuController = [ComponentManager getInteranlComponentNamed:
			@"OpenWithMenu"];
		openWithMenuDelegate = [[openWithMenuController buildMenuDelegate] retain];
		loadedOpenWithMenu = YES;
		//			[openWithMenuDelegate setDelegate:self];
		[openWithMenu setDelegate:openWithMenuDelegate];
		[item setSubmenu:openWithMenu];		
	}

	return enable;
}

//-----------------------------------------------------------------------------

/** This function loads the Favorites menu code from the proper bundle, and adds
 * the menu. It should be called only from -validateMenuItem:
 */
-(BOOL)validateFavoritesMenuItem:(NSMenuItem*)item
{
	[item setAction:nil];
	
	// Set up the Favorites Menu
	NSMenu* favoritesMenu = [[[NSMenu alloc] init] autorelease];
	favoritesMenuDelegate = [[ComponentManager getInteranlComponentNamed:
		@"FavoritesMenu"] buildMenuDelegate];
	[favoritesMenu setDelegate:favoritesMenuDelegate];
	[item setSubmenu:favoritesMenu];	
	
	return YES;
}

//-----------------------------------------------------------------------------

/** Checks to make sure the icon for the Computer entry in the goto menu is 
 * loaded. It should be called only from -validateMenuItem:
 */
-(BOOL)validateGoToComputerMenuItem:(NSMenuItem*)item
{
	// Set the icon if we don't have one yet.
	if(![item image])
	{
		NSImage* img = [[NSImage imageNamed:@"iMac"] copy];
		[img setScalesWhenResized:YES];
		[img setSize:NSMakeSize(16, 16)];
		[item setImage:img];
		[img release];
	}
	
	return YES;
}

//-----------------------------------------------------------------------------

/** Checks to make sure the icon for the Home entry in the goto menu is
 * loaded. It should be called only from -validateMenuItem:
 */
-(BOOL)validateGoToHomeDirectoryMenuItem:(NSMenuItem*)item
{
	// Set the icon if we don't have one yet.
	if(![item image])
	{
		NSImage* img = [[NSWorkspace sharedWorkspace] 
			iconForFile:NSHomeDirectory()];
		[img setSize:NSMakeSize(16, 16)];
		[item setImage:img];
	}	
	
	return YES;
}

//-----------------------------------------------------------------------------

/** Checks to make sure the icon for the Pictures entry in the goto menu is
 * loaded. This function also disables that menu item if there is no Pictures
 * folder. It should be called only from -validateMenuItem: 
 */
-(BOOL)validateGoToPicturesDirectoryMenuItem:(NSMenuItem*)item
{
	BOOL enable = [[NSHomeDirectory() 
		stringByAppendingPathComponent:@"Pictures"] isDir];
	
	// Set the icon if we haven't done so yet.
	if(![item image])
	{
		NSImage* img;
		if(enable)
		{
			img = [[[NSImage imageNamed:@"ToolbarPicturesFolderIcon"] copy] 
				autorelease];
			[img setScalesWhenResized:YES];
			[img setSize:NSMakeSize(16, 16)];
		}
		else
			img = [[NSImage alloc] initWithSize:NSMakeSize(16,16)];
		
		[item setImage:img];
	}
	
	return enable;
}

//-----------------------------------------------------------------------------

/** Returns the current file for the current main window. 
 *
 */
-(EGPath*)currentFile
{
	NSWindow* mainWindow = [NSApp mainWindow];
	NSWindowController* controller = [mainWindow windowController];
	ViewerDocument* document = [controller document];

	return [document currentFile];
}

-(IBAction)showPreferences:(id)sender
{
	if (!prefs) {
        // Determine path to the sample preference panes
		id ssPrefsFactory = [ComponentManager 
			getInteranlComponentNamed:@"SSPrefsController"];
		
		prefs = [[ssPrefsFactory buildWithPanesSearchPath:
			[[NSBundle mainBundle] builtInPlugInsPath] 
										  bundleExtension:@"VSPref"] retain];
        
        // Set which panes are included, and their order.
        [prefs setPanesOrder:[NSArray arrayWithObjects:
			NSLocalizedString(@"General", @"Name of General Preference Pane"),
			NSLocalizedString(@"Favorites", @"Name of Favorites Prefernce Pane"),
			NSLocalizedString(@"Keywords", @"Name of Keywords Preference Pane"),
			NSLocalizedString(@"Updating", @"Name of Updating Preference Pane"),
			NSLocalizedString(@"Advanced", @"Name of Advanced Preference Pange"),
			nil]];
    }
    
    // Show the preferences window.
    [prefs showPreferencesWindow];
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
	[self goToDirectory:[EGPath pathWithPath:NSHomeDirectory()]];
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
	[self goToDirectory:[EGPath pathWithPath:
		[NSHomeDirectory() stringByAppendingPathComponent:@"Pictures"]]];
}

//-----------------------------------------------------------------------------

/** Displays the GotoFolder sheet/modal dialog depending on if there's a 
 * displayed window.
 */
-(IBAction)goToFolder:(id)sender
{
	if([NSApp mainWindow]) 
	{
		id gotoDelegate = [[ComponentManager 
			getInteranlComponentNamed:@"GotoFolderSheet"] build];
		
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
		id gotoDelegate = [[ComponentManager	
			getInteranlComponentNamed:@"GotoFolderWindow"] build];
		
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
{}

/** Selector that doesn't do anything. It's detected at runtime through
 * -validateMenuItem:, and a submenu is generated.
 */
-(IBAction)fakeOpenWithMenuSelector:(id)sender
{}

//-----------------------------------------------------------------------------
-(void)becomeMainDocument:(id)mainDocument
{
//	NSLog(@"Main document is now %@, with the file %@", mainDocument,
//		  [mainDocument currentFile]);
	
	// Tell all loaded CurrentFilePlugins that things have changed!
	id components = [ComponentManager getLoadedCurrentFilePlugins];
	if([components count]) 
	{	
		[[components do] currentImageSetTo:[mainDocument currentFile]];
	}
}

-(void)resignMainDocument:(id)mainDocument
{
	if([[NSApp orderedDocuments] count] == 0)
	{
		[[[ComponentManager getLoadedCurrentFilePlugins] do] 
			currentImageSetTo:0];
	}
}

-(void)sendPluginActivationSignal:(id)menuItem
{
	NSDictionary* pluginLine = [menuItem representedObject];
	NSWindow* mainWindow = [NSApp mainWindow];
	EGPath* mainFile = [[[mainWindow windowController] document] currentFile];
	
	NSString* name = [pluginLine objectForKey:@"Plugin Name"];
	id component = [ComponentManager getCurrentFilePluginNamed:name];
	
	[component activatePluginWithFile:mainFile
							 inWindow:mainWindow
							  context:pluginLine];
}


@end
