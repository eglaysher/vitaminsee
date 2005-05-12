/////////////////////////////////////////////////////////////////////////
// File:          $Name$
// Module:        Main Controller Class
// Part of:       VitaminSEE
//
// ID:            $Id: VitaminSEEController.m 123 2005-04-18 00:21:02Z elliot $
// Revision:      $Revision$
// Last edited:   $Date$
// Author:        $Author$
// Copyright:     (c) 2005 Elliot Glaysher
// Created:       1/30/05
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

#include <sys/stat.h>

#import "VitaminSEEController.h"
#import "VitaminSEEController+PluginLayer.h"
#import "ToolbarDelegate.h"
#import "ViewIconViewController.h"
#import "EGPath.h"

//#import "FSNodeInfo.h"
//#import "FSBrowserCell.h"
#import "FavoritesMenuDelegate.h"
#import "FileSizeFormatter.h"
#import "SBCenteringClipView.h"
#import "ViewIconViewController.h"
#import "ViewAsIconViewCell.h"
#import "ImageTaskManager.h"
#import "Util.h"
#import "NSString+FileTasks.h"
#import "AppKitAdditions.h"
#import "PluginLayer.h"
#import "SortManagerController.h"
#import "IconFamily.h"
#import "ImmutableToMutableTransformer.h"
#import "SS_PrefsController.h"
#import "KeywordNode.h"
#import "ThumbnailManager.h"
#import "GotoSheetController.h"
#import "PluginLayer.h"
#import "PathExistsValueTransformer.h"
#import "FullDisplayNameValueTransformer.h"

#import "RBSplitView.h"
#import "RBSplitSubview.h"

@implementation VitaminSEEController
///////// TEST PLAN

/*
 * Moving a file into a directory where that file already exists.
 */

////////////////////////////////////////////////// WHERE TO GO FROM HERE...

/* COMPLETED:
 * * Disable show/hide toolbar and customize toolbar when window isn't displayed...
 * * Autosave main window position
 * * Close VS window, then open sort manager.
 * * Adding a thumbnail doesn't change a file's modification time (which makes
 *   more sense since we aren't really modifying the file).
 * * Option to show hidden files, plus hide stuff at the @"/" level by default.
 * * Advanced preference pane
 * * Thumbnails aren't displayed for files on remote server after generation (
 *   this could be fixed with a relod, but now it's not a problem...)
 * * Fix the !$#@ memory leak
 * * RBSplitView
 * * UTI types for 10.4 conformance
 * * Display names. Use the macintosh heiarchy instead of our own.
 * * Splitview Autosave position
 */

// 11th hour 0.6.1 fixes for ADA05:
// * Foucs behaviour. (Hacked into a good enough state for ADA)
// * Focus ring leaking on the sides. (Ugly hack in the nib)
// * Find why images don't display when left side eats screen. (Hacked to work in -redraw)
// * Updated to RBSplitView 1.1.2. Now MIT! woot.
// * Handle disk eject!!!!

// EMERGENCY TODO LIST:
// * Do paperwork

// Post 6.1 todo list
// * RBSplitView for the left column.
//   * Figure out how to make it less flickery when resizing

// For Version 0.7
// * Delete key in  sort manager preferences should do something. + UNDO!!!!
// * Fullscreen + Slideshow
// * Have thumbnails scale down if right side is shrunk (rework NSBrowserCell
//   subclass to use NSImageCell?)
// * Undo on delete. (0.7 by absolute latest!)
//   * Requires figuring out how the Mac trash system works; 
//     NSWorkspaceRecycleOperation isn't behaving how the Finder behaves. Maybe
//     the answer is in Carbon?

// For Version 0.8
// * Transparent archive support
// * Fit height/width
// * DnD on the ViewIconViewController
// * Mouse-wheel scrolling...
//   * Requires next/previous 
// * UNIT TESTING!

// For Version 0.9
// * Create an image database feature
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
// * Japanese Localization
//   * Requires localization of display names!
//     * General Preferences needs some kind of DisplayNameValueTransformer
//     * ViewAsIcons view needs ability to determine between display name and
//       actual name
// * Check for file on remote volume.

// KNOWN ISSUES:
// * GIF animation speed.
// * (Some) Animated GIFs broken in Tiger?
// * Very rare Kotoeri crash at startup. No clue what's causing it.
// * Disable labels in KeywordManager (wishlist)

/* Okay, refactoring responsibilities:
  * VitaminSEEController is responsible for ONLY:
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
	[defaultPrefs setObject:[NSNumber numberWithBool:NO] forKey:@"GenerateThumbnailsInArchives"];
	[defaultPrefs setObject:[NSNumber numberWithBool:YES] forKey:@"PreloadImages"];
	[defaultPrefs setObject:[NSNumber numberWithBool:NO] forKey:@"ShowHiddenFiles"];

	// Keyword preferences
	KeywordNode* node = [[[KeywordNode alloc] initWithParent:nil keyword:@"Keywords"] autorelease];
	NSData* emptyKeywordNode = [NSKeyedArchiver archivedDataWithRootObject:node];
	[defaultPrefs setObject:emptyKeywordNode forKey:@"KeywordTree"];
	
	// Default sort manager array
	NSArray* sortManagerPaths;
	if(hasPictures)
		sortManagerPaths = [NSArray arrayWithObjects:
			[NSDictionary dictionaryWithObjectsAndKeys:@"Pictures", @"Name",
				[NSHomeDirectory() stringByAppendingPathComponent:@"Pictures"], 
						@"Path", nil], nil];
	else
		sortManagerPaths = [NSArray arrayWithObjects:
			[NSDictionary dictionaryWithObjectsAndKeys:@"Home", @"Name",
				NSHomeDirectory(), @"Path", nil], nil];
	
	[defaultPrefs setObject:sortManagerPaths forKey:@"SortManagerPaths"];
	[defaultPrefs setObject:[NSNumber numberWithBool:YES] forKey:@"SortManagerInContextMenu"];
	
	[[NSUserDefaults standardUserDefaults] registerDefaults: defaultPrefs];
}

- (void)awakeFromNib
{
	// Set up the file viewer on the left
	viewAsIconsController = [self viewAsIconsControllerPlugin];
	[self setViewAsView:[viewAsIconsController view]];
	[viewAsIconsController connectKeyFocus:scrollView];
	[viewerWindow setInitialFirstResponder:[viewAsIconsController view]];
	
	// Set up the scroll view on the right
	id docView = [[scrollView documentView] retain];
	id newClipView = [[SBCenteringClipView alloc] initWithFrame:[[scrollView 
		contentView] frame]];
	[newClipView setBackgroundColor:[NSColor windowBackgroundColor]];
	[scrollView setContentView:(NSClipView*)newClipView];
	[newClipView release];
	[scrollView setDocumentView:docView];
	[docView release];
	
	// Set the scroll view to accept input
	[scrollView setFocusRingType:NSFocusRingAbove];
	
	// Use our file size formatter for formating the "[image size]" text label
	FileSizeFormatter* fsFormatter = [[[FileSizeFormatter alloc] init] autorelease];
	[[fileSizeLabel cell] setFormatter:fsFormatter];
	
	[self setupToolbar];
	scaleProportionally = NO;
	scaleRatio = 1.0;
	
	// Set up our split view
	[splitView setDelegate:self];
	RBSplitSubview* leftView = [splitView subviewAtPosition:0];
	[leftView setCanCollapse:YES];
	[leftView setMinDimension:92 andMaxDimension:0];
	RBSplitSubview* rightView = [splitView subviewAtPosition:1];
	[rightView setCanCollapse:NO];
	[rightView setMinDimension:0 andMaxDimension:0];
	
	// Restore the settings for the split view
	[splitView setAutosaveName:@"MainWindowSplitView" recursively:YES];
	[splitView restoreState:YES];
	
	// Set our plugins to nil
	loadedBasePlugins = [[NSMutableDictionary alloc] init];
	loadedViewPlugins = [[NSMutableDictionary alloc] init];
	loadedCurrentFilePlugins = [[NSMutableDictionary alloc] init];
	
	// Use an Undo manager to manage moving back and forth.
	pathManager = [[NSUndoManager alloc] init];	
	
	// Launch the other threads and tell them to connect back to us.
	imageTaskManager = [[ImageTaskManager alloc] initWithController:self];
	thumbnailManager = [[ThumbnailManager alloc] initWithController:self];

	setPathForFirstTime = NO;
}

-(void)dealloc
{
	[pathManager release];
	[splitView saveState:YES];
	[super dealloc];
}

////////////////////////////////////////////////////////// APPLICATION DELEGATE

// This initialization can safely be delayed until after the main window has
// been shown.
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	if(!setPathForFirstTime)
	{
		[viewAsIconsController setCurrentDirectory:[EGPathFilesystemPath 
			pathWithPath:[[NSUserDefaults standardUserDefaults] 
				objectForKey:@"DefaultStartupPath"]] currentFile:nil];
	}
	
	// Make the icon view the first responder since the previous enable
	// makes directoryDropdown FR.
	[viewAsIconsController makeFirstResponderTo:mainVitaminSeeWindow];
}

-(BOOL)application:(NSApplication*)theApplication openFile:(NSString*)filename
{	
	if([filename isImage])
	{		
		// Clear the current image. (Do this now since there's the possibility
		// that the new image won't load in time for display latter on.)
		[self setCurrentFile:nil];
		
		[viewAsIconsController setCurrentDirectory:[EGPathFilesystemPath pathWithPath:[filename stringByDeletingLastPathComponent]]
									   currentFile:filename];
		
		// Show the window if hidden. (Do this now so there isn't a flash from
		// the previous directory) 
		if(![mainVitaminSeeWindow isVisible])
			[self toggleVitaminSee:self];		
	}
	else if([filename isDir])
	{
		// Show the window
		if(![mainVitaminSeeWindow isVisible])
			[self toggleVitaminSee:self];
		
		[viewAsIconsController setCurrentDirectory:[EGPathFilesystemPath pathWithPath:filename]
									   currentFile:nil];
	}
	else
		return NO;

	setPathForFirstTime = YES;
	return YES;
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)theApplication 
					hasVisibleWindows:(BOOL)hasVisibleWindows
{
	NSLog(@"In applicationShouldHandleReopen");
	if(![mainVitaminSeeWindow isVisible])
	{
		// Now display the window
		[self toggleVitaminSee:self];
	}
}

- (void)windowWillClose:(NSNotification *)aNotification
{
	// Tell all the plugins that there's no file.
	[self setPluginCurrentFileTo:nil];
}

-(void)displayAlert:(NSString*)message informativeText:(NSString*)info 
		 helpAnchor:(NSString*)anchor
{
	NSAlert *alert = [[[NSAlert alloc] init] autorelease];
	[alert addButtonWithTitle:@"OK"];
	[alert setMessageText:message];

	if(info)
		[alert setInformativeText:info];

	// If we have a help anchor, set things up so a help button is available.
	if(anchor)
	{
		[alert setHelpAnchor:anchor];
		[alert setShowsHelp:YES];
		[alert setDelegate:self];
	}
	
	[alert setAlertStyle:NSWarningAlertStyle];
	[alert beginSheetModalForWindow:mainVitaminSeeWindow
					  modalDelegate:nil
					 didEndSelector:nil
						contextInfo:nil];
}

-(BOOL)alertShowHelp:(NSAlert *)alert 
{	
	[[NSHelpManager sharedHelpManager] openHelpAnchor:[alert helpAnchor]
											   inBook:@"VitaminSEE Help"];
    return YES;
}

// ============================================================================
//                         FILE VIEW SELECTION
// ============================================================================
// Changing the user interface
- (void)setViewAsView:(NSView*)nextView
{
	[currentFileViewHolder setSubview:nextView];
}

-(IBAction)openFolder:(id)sender;
{
	[viewAsIconsController doubleClick:nil];
}

-(IBAction)closeWindow:(id)sender
{
	[mainVitaminSeeWindow close];
}

-(IBAction)referesh:(id)sender
{
	NSString* directory = [currentImageFile stringByDeletingLastPathComponent];
	[viewAsIconsController setCurrentDirectory:[EGPathFilesystemPath pathWithPath:directory]
								   currentFile:currentImageFile];
}

-(IBAction)toggleFileList:(id)sender
{
	RBSplitSubview* firstSplit = [splitView subviewAtPosition:0];
	if ([firstSplit isCollapsed]) {
		[firstSplit expandWithAnimation:NO withResize:NO];
	} else {
		[firstSplit collapseWithAnimation:NO withResize:NO];
	}
}

-(IBAction)revealInFinder:(id)sender
{
	[[NSWorkspace sharedWorkspace] selectFile:currentImageFile
					 inFileViewerRootedAtPath:@""];
}

-(IBAction)viewInPreview:(id)sender
{
	[[NSWorkspace sharedWorkspace]	openFile:currentImageFile
							 withApplication:@"Preview"];
}

-(IBAction)goPreviousFile:(id)sender
{
	[viewAsIconsController goPreviousFile];
}

-(IBAction)goNextFile:(id)sender
{
	[viewAsIconsController goNextFile];
}

-(IBAction)goEnclosingFolder:(id)sender
{
	[viewAsIconsController goEnclosingFolder];
}

-(IBAction)goBack:(id)sender
{
	[pathManager undo];
	[viewAsIconsController makeFirstResponderTo:mainVitaminSeeWindow];
}

-(IBAction)goForward:(id)sender
{
	[pathManager redo];
	[viewAsIconsController makeFirstResponderTo:mainVitaminSeeWindow];
}

-(IBAction)goToHomeFolder:(id)sender
{
	if(![mainVitaminSeeWindow isVisible])
		[self toggleVitaminSee:self];
	[viewAsIconsController setCurrentDirectory:[EGPathFilesystemPath pathWithPath:NSHomeDirectory()]
								   currentFile:nil];
}

-(IBAction)goToPicturesFolder:(id)sender
{
	if(![mainVitaminSeeWindow isVisible])
		[self toggleVitaminSee:self];

	[viewAsIconsController setCurrentDirectory:[EGPathFilesystemPath
		pathWithPath:[NSHomeDirectory() 
			stringByAppendingPathComponent:@"Pictures"]]
								   currentFile:nil];
}

-(IBAction)fakeFavoritesMenuSelector:(id)sender
{
}

-(IBAction)goToFolder:(id)sender
{
	[[self gotoFolderController] showSheet:mainVitaminSeeWindow
							  initialValue:@""
									target:self
								  selector:@selector(finishedGotoFolder:)];
}

-(void)finishedGotoFolder:(NSString*)done
{
	if([done isDir])
	{
		// Clear the current image. (Do this now since there's the possibility
		// that the new image won't load in time for display latter on.)
		if(![mainVitaminSeeWindow isVisible])
			[self setCurrentFile:nil];
		
		[viewAsIconsController setCurrentDirectory:[EGPathFilesystemPath pathWithPath:done]
									   currentFile:nil];
		
		// Show the window if hidden. (Do this now so there isn't a flash from
		// the previous directory)
		if(![mainVitaminSeeWindow isVisible])
			[self toggleVitaminSee:self];
	}
	else
		// Beep at the user...
		AlertSoundPlay();
}
	
-(id)loadComponentNamed:(NSString*)name fromBundle:(NSString*)path
{
	NSString *bundlePath = [[[NSBundle mainBundle] builtInPlugInsPath]
			stringByAppendingPathComponent:path];
	NSBundle *windowBundle = [NSBundle bundleWithPath:bundlePath];	
	id component;

	if(windowBundle)
	{
		Class windowControllerClass = [windowBundle principalClass];
		if(windowControllerClass)
		{
			if([windowControllerClass conformsToProtocol:@protocol(CurrentFilePlugin)])
			{
				component = [[windowControllerClass alloc] initWithPluginLayer:
					[PluginLayer pluginLayerWithController:self]];
				[loadedCurrentFilePlugins setValue:component forKey:name];				
			}
			else if([windowControllerClass conformsToProtocol:@protocol(FileView)])
			{
				component = [[windowControllerClass alloc] initWithPluginLayer:
					[PluginLayer pluginLayerWithController:self]];
				[loadedViewPlugins setValue:component forKey:name];				
			}
			else if([windowControllerClass conformsToProtocol:@protocol(PluginBase)])
			{
				component = [[windowControllerClass alloc] initWithPluginLayer:
					[PluginLayer pluginLayerWithController:self]];
				[loadedBasePlugins setValue:component forKey:name];
			}
			else
				NSLog(@"WARNING! Attempt to load plugin from '%@' that doesn't conform to PluginBase!",
					  path);
		}
	}
	
	return component;
}
	
-(id)sortManagerController
{
	id sortManager = [loadedCurrentFilePlugins objectForKey:@"SortManagerController"];
	if(!sortManager)
	{
		sortManager = [self loadComponentNamed:@"SortManagerController"
									fromBundle:@"SortManager.cqvPlugin"];
		[sortManager fileSetTo:([mainVitaminSeeWindow isVisible] ? currentImageFile : nil )];
	}
	return sortManager;
}

-(id)keywordManagerController
{
	id keywordManager = [loadedCurrentFilePlugins objectForKey:@"KeywordManagerController"];
	if(!keywordManager)
	{
		keywordManager = [self loadComponentNamed:@"KeywordManagerController"
									   fromBundle:@"KeywordManager.cqvPlugin"];
		[keywordManager fileSetTo:([mainVitaminSeeWindow isVisible] ? currentImageFile : nil )];
	}
	
	return keywordManager;
}

-(id)gotoFolderController
{
	id gotoFolderController = [loadedBasePlugins objectForKey:@"GotoFolderController"];
	if(!gotoFolderController)
		gotoFolderController = [self loadComponentNamed:@"GotoFolderController"
											 fromBundle:@"GotoFolderSheet.bundle"];
	return gotoFolderController;	
}

-(id)viewAsIconsControllerPlugin
{
	id plugin = [loadedViewPlugins objectForKey:@"ViewAsIconsController"];
	if(!plugin)
		plugin = [self loadComponentNamed:@"ViewAsIconsController"
							   fromBundle:@"ViewAsIconsFileView.bundle"];
	return plugin;
}

-(id)imageMetadataPlugin
{
	id imageMetadataPlugin = [loadedBasePlugins objectForKey:@"ImageMetadata"];
	if(!imageMetadataPlugin)
		imageMetadataPlugin = [self loadComponentNamed:@"ImageMetadata"
											fromBundle:@"ImageMetadata.bundle"];
	
	return imageMetadataPlugin;
}

-(void)toggleVisible:(NSWindow*)window
{
	if([window isVisible])
		[window close];
	else
		[window makeKeyAndOrderFront:self];	
}

-(IBAction)toggleVitaminSee:(id)sender
{
	if([mainVitaminSeeWindow isVisible])
		[mainVitaminSeeWindow close];
	else
	{
		[self setPluginCurrentFileTo:currentImageFile];
		[mainVitaminSeeWindow makeKeyAndOrderFront:self];
	}
}

-(IBAction)toggleSortManager:(id)sender
{	
	[self toggleVisible:[[self sortManagerController] window]];
}

-(IBAction)toggleKeywordManager:(id)sender
{
	[self toggleVisible:[[self keywordManagerController] window]];
}

-(BOOL)validateMenuItem:(NSMenuItem *)theMenuItem
{
    BOOL enable = [self respondsToSelector:[theMenuItem action]];
	BOOL mainWindowVisible = [mainVitaminSeeWindow isVisible];
	SEL action = [theMenuItem action];
	
	if(action == @selector(openFolder:))
	{
		enable = mainWindowVisible && [currentImageFile isDir];
	}
	else if(action == @selector(closeWindow:) ||
			action == @selector(referesh:))
	{
		enable = mainWindowVisible;
	}
	else if(action == @selector(addCurrentDirectoryToFavorites:))
	{
		enable = mainWindowVisible && [currentImageFile isDir] && 
			[self isInFavorites:currentImageFile];
	}
	else if(action == @selector(deleteFileClicked:))
	{
		enable = mainWindowVisible && [[viewAsIconsController selectedFiles] count];
	}
	// View Menu
	else if (action == @selector(actualSize:))
	{
		enable = mainWindowVisible && [currentImageFile isImage] && 
			!(scaleProportionally && scaleRatio == 1.0);
	}
	else if(action == @selector(zoomToFit:))
	{
		enable = mainWindowVisible && [currentImageFile isImage] && scaleProportionally;
	}
	else if (action == @selector(zoomIn:) ||
			 action == @selector(zoomOut:))
	{
		enable = mainWindowVisible && [currentImageFile isImage];
	}
	else if(action == @selector(revealInFinder:))
	{
		enable = mainWindowVisible && [[viewAsIconsController selectedFiles] count];
	}
	else if(action == @selector(toggleFileList:))
	{
		enable = mainWindowVisible;
		
		if([[splitView subviewAtPosition:0] isCollapsed])
			[theMenuItem setTitle:NSLocalizedString(@"Show File List", @"Text in View menu")];
		else
			[theMenuItem setTitle:NSLocalizedString(@"Hide File List", @"Text in View menu")];
	}
	else if(action == @selector(viewInPreview:))
	{
		enable = mainWindowVisible && [currentImageFile isImage];
	}
	else if(action == @selector(toggleToolbarShown:))
	{
		enable = mainWindowVisible;
		
		// Set the menu item to the correct state
		if([[mainVitaminSeeWindow toolbar] isVisible])
			[theMenuItem setTitle:NSLocalizedString(@"Hide Toolbar", @"Text in View menu")];
		else
			[theMenuItem setTitle:NSLocalizedString(@"Show Toolbar", @"Text in View menu")];
	}
	else if(action == @selector(runToolbarCustomizationPalette:))
	{
		enable = mainWindowVisible;
	}
	// Go Menu
	else if (action == @selector(goNextFile:))
	{
		enable = mainWindowVisible && [viewAsIconsController canGoNextFile];
	}
	else if (action == @selector(goPreviousFile:))
	{
		enable = mainWindowVisible && [viewAsIconsController canGoPreviousFile];
	}
    else if (action == @selector(goEnclosingFolder:))
    {
		// You can go up as long as there is a thing to go back on...
        enable = mainWindowVisible && [viewAsIconsController canGoEnclosingFolder];
    }
    else if (action == @selector(goBack:))
    {
        enable = mainWindowVisible && [pathManager canUndo];
    }
	else if (action == @selector(goForward:))
	{
		enable = mainWindowVisible && [pathManager canRedo];
	}
	else if (action == @selector(goToHomeFolder:))
	{
		// Set the icon if we don't have one yet.
		if(![theMenuItem image])
		{
			NSImage* img = [[NSWorkspace sharedWorkspace] iconForFile:NSHomeDirectory()];
			[img setSize:NSMakeSize(16, 16)];
			[theMenuItem setImage:img];
		}
	}
	else if (action == @selector(goToPicturesFolder:))
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
	else if (action == @selector(goToFolder:))
	{
		enable = mainWindowVisible;
	}
	else if (action == @selector(fakeFavoritesMenuSelector:))
	{
		[theMenuItem setAction:nil];
		
		// Set up the Favorites Menu
		NSMenu* favoritesMenu = [[[NSMenu alloc] init] autorelease];
		favoritesMenuDelegate = [[FavoritesMenuDelegate alloc] initWithController:self];
		[favoritesMenu setDelegate:favoritesMenuDelegate];
		[theMenuItem setSubmenu:favoritesMenu];		
	}

    return enable;
}

- (void)setCurrentFile:(NSString*)newCurrentFile
{
	// CHECK THIS OUT LATER!!!!
	[newCurrentFile retain];
	[currentImageFile release];
	currentImageFile = newCurrentFile;
	
	// Okay, we don't know what kind of thing we have been passed, so let's
	BOOL isDir = [newCurrentFile isDir];
	if((newCurrentFile && isDir) || !currentImageFile)
		[fileSizeLabel setObjectValue:@"---"];
	else
		[fileSizeLabel setObjectValue:[NSNumber 
			numberWithInt:[newCurrentFile fileSize]]];
	
	if(![newCurrentFile isImage])
		[imageSizeLabel setStringValue:@"---"];
	
	[self setPluginCurrentFileTo:newCurrentFile];

	[self redraw];
}

-(void)setPluginCurrentFileTo:(NSString*)newCurrentFile
{
	// Alert all the plugins of the new file:
	NSEnumerator* e = [loadedCurrentFilePlugins objectEnumerator];
	id <CurrentFilePlugin> plugin;
	while(plugin = [e nextObject])
		[plugin fileSetTo:newCurrentFile];	
}

-(void)preloadFile:(NSString*)file
{
	if([[[NSUserDefaults standardUserDefaults] objectForKey:@"PreloadImages"] boolValue])
		[imageTaskManager preloadImage:file];
}

-(void)redraw
{
	// UGLY HACK TO GET HIS WORKING BY ADA05!!!!
	// There's an image cacheing exception if there's no place to place the image
	// (this makes no sense), so hard code it so that this condition can't happen.
	if([[splitView subviewAtPosition:1] dimension] < 20)
		return;
	
	[imageSizeLabel setStringValue:@"---"];
	
	if(!currentImageFile)
	{
		// Set nothing.
		[imageViewer setImage:nil];	
	}
	else
	{
		// Tell the ImageTaskManager our current options
		[imageTaskManager setSmoothing:[[[NSUserDefaults standardUserDefaults]
		objectForKey:@"SmoothingTag"] intValue]];
		[imageTaskManager setScaleProportionally:scaleProportionally];
		[imageTaskManager setScaleRatio:scaleRatio];
		[imageTaskManager setContentViewSize:[scrollView contentSize]];		
		
		// Tell the ImageTaskManager to load the file and contact us when done
		[self startProgressIndicator];
		[imageTaskManager displayImageWithPath:currentImageFile];
	}
}

-(IBAction)zoomIn:(id)sender
{
	scaleProportionally = YES;
	scaleRatio = scaleRatio + 0.10f;
	[self redraw];
}

-(IBAction)zoomOut:(id)sender
{
	scaleProportionally = YES;
	scaleRatio = scaleRatio - 0.10;
	if(scaleRatio <= 0)
		scaleRatio = 0.05;
	[self redraw];
}

-(IBAction)zoomToFit:(id)sender
{
	scaleProportionally = NO;
	scaleRatio = 1.0;
	[self redraw];
}

-(IBAction)actualSize:(id)sender
{
	scaleProportionally = YES;
	scaleRatio = 1.0;
	[self redraw];
}

-(void)willAdjustSubviews:(id)rbview
{
//	[imageViewer setImage:nil];
}

// Redraw the window when the window resizes.
//-(void)windowDidResize:(NSNotification*)notification
-(void)didAdjustSubviews:(id)rbview
{
	[self redraw];
}

- (void)splitView:(RBSplitView*)sender didCollapse:(RBSplitSubview*)subview
{
	// When we collapse, give the image viewer focus
	[scrollView setNextKeyView:nil];
	[mainVitaminSeeWindow makeFirstResponder:scrollView];
	[mainVitaminSeeWindow setViewsNeedDisplay:YES];
	[imageViewer setNextKeyView:imageViewer];
}

- (void)splitView:(RBSplitView*)sender didExpand:(RBSplitSubview*)subview 
{
	// When we expand, make the file view first responder
	[viewAsIconsController makeFirstResponderTo:mainVitaminSeeWindow];
	[viewAsIconsController connectKeyFocus:scrollView];
	[mainVitaminSeeWindow setViewsNeedDisplay:YES];
}

- (void)splitView:(RBSplitView*)sender wasResizedFrom:(float)oldDimension to:(float)newDimension
{
	[mainVitaminSeeWindow setViewsNeedDisplay:YES];
}

// Redraw the window when the seperator between the file list and image view
// is moved.
-(void)splitViewDidResizeSubviews:(NSNotification*)notification
{
	[viewAsIconsController clearCache];
	[self redraw];
}

// Callback function for ImageTaskManager. Gets called when an image is to be
// displayed in the window...
-(void)displayImage
{
	// Get the current image from the ImageTaskManager
	int x, y;
	float scale;
	NSImage* image = [imageTaskManager getCurrentImageWithWidth:&x height:&y 
														  scale:&scale];

	[imageViewer setImage:image];
	[imageViewer setFrameSize:[image size]];
	[imageViewer setAnimates:YES];
	
	// Set the correct cursor.
	if([image size].width > [scrollView contentSize].width ||
	   [image size].height > [scrollView contentSize].height)
	{
		if(!handCursor)
			handCursor = [[NSCursor alloc] initWithImage:[NSImage 
				imageNamed:@"hand_open"] hotSpot:NSMakePoint(8, 8)];
		[(NSScrollView*)[imageViewer superview] setDocumentCursor:handCursor];
	}
	else
		[(NSScrollView*)[imageViewer superview] setDocumentCursor:nil];
	
	scaleRatio = scale;

	if([currentImageFile isDir])
		[imageSizeLabel setStringValue:@"---"];
	else
		[imageSizeLabel setStringValue:[NSString stringWithFormat:@"%i x %i", 
			x, y]];
}

-(void)setIcon
{
	NSImage* thumbnail = [thumbnailManager getCurrentThumbnail];
	NSString* path = [thumbnailManager getCurrentPath];

	[viewAsIconsController setThumbnail:thumbnail forFile:path];

	// Release the current icon
	[thumbnail release];
}

// Progress indicator control
-(void)startProgressIndicator
{
	[scrollView setNeedsDisplay:YES];
	[progressIndicator setHidden:NO];
	[progressIndicator startAnimation:self];
}

-(void)stopProgressIndicator
{
	[scrollView setNeedsDisplay:YES];
	[progressIndicator stopAnimation:self];
	[progressIndicator setHidden:YES];
}

-(void)setStatusText:(NSString*)statusText
{
	if(statusText)
	{
		[progressCurrentTask setStringValue:statusText];		
		[progressCurrentTask setHidden:NO];
	}
	else
		[progressCurrentTask setHidden:YES];

	[scrollView setNeedsDisplay:YES];
}

-(IBAction)showPreferences:(id)sender
{
	if (!prefs) {
        // Determine path to the sample preference panes
        
        prefs = [[SS_PrefsController alloc] initWithPanesSearchPath:
		 [[NSBundle mainBundle] builtInPlugInsPath] bundleExtension:@"cqvPref"];
        
        // Set which panes are included, and their order.
        [prefs setPanesOrder:[NSArray arrayWithObjects:@"General",
			@"Favorites", @"Keywords", @"Updating", @"Advanced",
			@"A Non-Existent Preference Pane", nil]];
    }
    
    // Show the preferences window.
    [prefs showPreferencesWindow];
}

-(IBAction)deleteFileClicked:(id)sender
{
	[self deleteFile:[self currentFile]];
}

-(IBAction)showGPL:(id)sender
{
	[[NSWorkspace sharedWorkspace] openFile:[[NSBundle mainBundle] 
		pathForResource:@"GPL"
				 ofType:@"txt"]];
}

-(IBAction)addCurrentDirectoryToFavorites:(id)sender
{
	// Adds the currently selected directory to the favorites menu
	if([currentImageFile isDir])
	{
		NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
		NSMutableArray* favoritesArray = [[userDefaults objectForKey:
			@"SortManagerPaths"] mutableCopy];
		
		NSDictionary* newItem = [NSDictionary dictionaryWithObjectsAndKeys:
			[currentImageFile lastPathComponent], @"Name",
			currentImageFile, @"Path", nil];
		[favoritesArray addObject:newItem];
		[userDefaults setValue:favoritesArray forKey:@"SortManagerPaths"];
		
		[favoritesArray release];
	}
}

-(BOOL)isInFavorites:(NSString*)path
{
	BOOL enable = YES;
	NSEnumerator* e = [[[NSUserDefaults standardUserDefaults]
			objectForKey:@"SortManagerPaths"] objectEnumerator];
	NSString* thisPath;
	while(thisPath = [[e nextObject] objectForKey:@"Path"])
	{
		if([thisPath isEqual:path])
		{
			enable = NO;
			break;
		}
	}
	
	return enable;
}

// These two functions are here so that -[VitaminSEEController validateMenu:]
// get's used.
-(IBAction)toggleToolbarShown:(id)sender
{
	[mainVitaminSeeWindow toggleToolbarShown:sender];
}

-(IBAction)runToolbarCustomizationPalette:(id)sender
{
	[mainVitaminSeeWindow runToolbarCustomizationPalette:sender];
}

@end
