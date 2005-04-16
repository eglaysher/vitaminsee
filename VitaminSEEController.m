#include <sys/stat.h>

#import "VitaminSEEController.h"
#import "ToolbarDelegate.h"
#import "ViewIconViewController.h"

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

@implementation VitaminSEEController
///////// TEST PLAN

/*
 * Moving a file into a directory where that file already exists.
 */


/////////////////////////////////////////////////////////// WHAT HAS BEEN DONE:
/**
  * Select child folder on "Go Enclosing folder"
  * Actual size zoom button
  * Modify IconFamily to have a black line around thumbnail.
  * Implement backHistory/forwardHistory
  * Icons in path viewer [to emphasise that they are folders.
  * Cell drawing
  * Sort manager
  * Preferences [Pretty much done. I can add new stuff when I want...]
  * Keywords
*/

/** Bugs fixed:
  * Highlighting gets screwed up when deleting a file...
  */

/** Polishes completed:
  * Hide "." files...
  * command-1 should TOGGLE the display of windows...
  * File renaming (Inspector!)
  * Cmd-O opens == double click.

  * Comments
  * Disable comments on things we can't comment on.
  * Placeholder for folders.
  * Validate menu items
  * Icons for VitaminSee
  * Reveal in Finder
  * VitaminSEE icon.
  * Go to folder sheet.

  * Integrated Help
  * Icon for SortManager (but it's crapy)
  * Icons for KeywordManager in Preferences (but it's even worse)
*/

////////////////////////////////////////////////// WHERE TO GO FROM HERE...


/* Completed:
 * * Speed. 
 * * * Entering a new directory is over an order of magnitude faster on
 *     directories with lots of images! (It took 17 seconds to enter my 
 *     Wallpaper directory with v0.5.3. Now it takes less then a second)
 * * * Cut application bloat. Not everybody uses Keyword support, so don't
 *     load it at startup. (Cuts 3/4 of a second off of startup)
 * * * More intelligent preloading behaviour in ViewIconViewController
 * * Stop assuming people have a "Pictures" folder. Some people have broken out
 *   of Apple's heiarchy, so don't make assumptions.
 * * Windows Bitmap support
 * * ICNS support
 * * Redo left panel as loadable bundle
 * * Requires a working plugin layer...
 * * Solidify the plugin layer
 * * Validate each folder in the Sort Manager just in case the user has deleted the folder.
 * * Favorites menu (available as both an item on the Go menu and as a toolbar dropdown)
 * * Mouse grab scrolling when it doesn't fit.
 * * Misnamed files (JPEG files ending in GIF, PNG files ending in JPG) get displayed, instead
 *   of an error.
 * * Undo/Redo on sort manager/rename, et cetera
 */

// * Stop building thumbnails when you leave a directory (finished?)

// * Known issue: Copying a file, then deleting the copy, leaves the undo operation
//   on the undo stack. I need to figure out how to fix this...

/// For Version 0.6
// * Check for file on remote volume.
// * Add undo to the rest of file operations?
//   * Delete
//   * Rename
// * Clean up ViewIconViewController
// * Cache control. How large?
// * Move to trash in wrong spot?

// * Japanese Localization
// * Mouse-wheel scrolling...
// * Dogfood it for at least a week and a half...

// For Version 0.7
// * Transparent archive support
// * Fit height/width
// * Fullscreen mode
// * Undo on delete.
// * UNIT TESTING!

// For Version 0.8
// * Create an image database feature
// * Add metadata for PNG and GIF
// * 2 million% more complete metadata! Exif panel! IPTC panel!

// For Version 0.9
// * Image search
// * Duplicate/similarity search
// * Finder notifications (a.k.a. don't make the user refresh)

// For Version 1.0
// ??????

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

/*
 * Neccessary changes to the SortManager:
 * * See if I can solve the problem of the panel gaining focus.
 * * Undo/redo for moving files!
 * * Undo/redo for everything else.
 * * Make localizable
 */

+ (void)initialize 
{
	// Set up our custom NSValueTransformer
	[NSValueTransformer setValueTransformer:[[[ImmutableToMutableTransformer 
		alloc] init] autorelease] forName:@"ImmutableToMutableTransformer"];
	[NSValueTransformer setValueTransformer:[[[PathExistsValueTransformer alloc]
		init] autorelease] forName:@"PathExistsValueTransformer"];
	
	// Test to see if the user is a rebel and deleted the Pictures folder
	struct stat buffer;
	NSString* picturesFolder = [NSHomeDirectory() stringByAppendingPathComponent:@"Pictures"];
	BOOL hasPictures = !(lstat([picturesFolder fileSystemRepresentation], &buffer)) &&
		buffer.st_mode && S_IFDIR;
	
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
	
	[imageViewer setAnimates:YES];
	[imageViewer setImage:nil];	
	
	// Use our file size formatter for formating the "[image size]" text label
	FileSizeFormatter* fsFormatter = [[[FileSizeFormatter alloc] init] autorelease];
	[[fileSizeLabel cell] setFormatter:fsFormatter];
	
	// Set up the icon for Home. (Do this at runtime so the correct icon gets
	// put up in the case of FileVault)
	NSImage* img = [[NSWorkspace sharedWorkspace] iconForFile:NSHomeDirectory()];
	[img setSize:NSMakeSize(16, 16)];
	[homeFolderMenuItem setImage:img];

	// Set up the icon for ~/Pictures. (Do this at runtime so that we don't get
	// the default file icon in case "~/Pictures" doesn't exist.)
	if([[NSHomeDirectory() stringByAppendingPathComponent:@"Pictures"] isDir])
	{
		img = [[NSWorkspace sharedWorkspace] iconForFile:
			[NSHomeDirectory() stringByAppendingPathComponent:@"Pictures"]];
		[img setSize:NSMakeSize(16, 16)];
	}
	else
		img = [[NSImage alloc] initWithSize:NSMakeSize(16,16)];
	[pictureFolderMenuItem setImage:img];
	
	// Set up the Favorites Menu
	NSMenu* favoritesMenu = [[[NSMenu alloc] init] autorelease];
	favoritesMenuDelegate = [[FavoritesMenuDelegate alloc] initWithController:self];
	[favoritesMenu setDelegate:favoritesMenuDelegate];
	[favoritesMenuItem setSubmenu:favoritesMenu];
	
	[self setupToolbar];
	[self zoomToFit:self];
	
	// Set our plugins to nil
	loadedBasePlugins = [[NSMutableDictionary alloc] init];
	loadedViewPlugins = [[NSMutableDictionary alloc] init];
	loadedCurrentFilePlugins = [[NSMutableDictionary alloc] init];
	
	// Use an Undo manager to manage moving back and forth.
	pathManager = [[NSUndoManager alloc] init];	
	
	handCursor = [[NSCursor alloc] initWithImage:[NSImage 
		imageNamed:@"hand_open"] hotSpot:NSMakePoint(8, 8)];
	
	// Launch the other threads and tell them to connect back to us.
	imageTaskManager = [[ImageTaskManager alloc] initWithController:self];
	thumbnailManager = [[ThumbnailManager alloc] initWithController:self];
}

-(void)dealloc
{
	[pathManager release];
}

////////////////////////////////////////////////////////// APPLICATION DELEGATE

// This initialization can safely be delayed until after the main window has
// been shown.
- (void)applicationWillFinishLaunching:(NSNotification *)aNotification
{
	// Whirl ourselves
	[self startProgressIndicator];
	// set our current directory 
	[viewAsIconsController setCurrentDirectory:[[NSUserDefaults standardUserDefaults] 
		objectForKey:@"DefaultStartupPath"] currentFile:nil];
	[self stopProgressIndicator];
	
	// Make the icon view the first responder since the previous enable
	// makes directoryDropdown FR.
	[viewAsIconsController makeFirstResponderTo:mainVitaminSeeWindow];
}

// fixme: Make this better
-(BOOL)application:(NSApplication*)theApplication openFile:(NSString*)filename
{	
	if([filename isImage])
	{
		// Show the window
		if(![mainVitaminSeeWindow isVisible])
			[self toggleVitaminSee:self];
		
		[viewAsIconsController setCurrentDirectory:[filename stringByDeletingLastPathComponent] 
							 currentFile:filename];
	}
	else if([filename isDir])
	{
		// Show the window
		if(![mainVitaminSeeWindow isVisible])
			[self toggleVitaminSee:self];
		
		[viewAsIconsController setCurrentDirectory:filename currentFile:nil];
	}
	else
		return NO;

	return YES;
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
//	currentFileView = nextView;
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
	[viewAsIconsController setCurrentDirectory:directory
								   currentFile:currentImageFile];
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
	[viewAsIconsController setCurrentDirectory:NSHomeDirectory() currentFile:nil];
}

-(IBAction)goToPicturesFolder:(id)sender
{
	if(![mainVitaminSeeWindow isVisible])
		[self toggleVitaminSee:self];

	[viewAsIconsController setCurrentDirectory:[NSHomeDirectory() 
		stringByAppendingPathComponent:@"Pictures"] currentFile:nil];
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
		[viewAsIconsController setCurrentDirectory:done currentFile:nil];
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
		sortManager = [self loadComponentNamed:@"SortManagerController"
									fromBundle:@"SortManager.cqvPlugin"];

	return sortManager;
}

-(id)keywordManagerController
{
	id keywordManager = [loadedCurrentFilePlugins objectForKey:@"KeywordManagerController"];
	if(!keywordManager)
	{
		keywordManager = [self loadComponentNamed:@"KeywordManagerController"
									   fromBundle:@"KeywordManager.cqvPlugin"];
		if(keywordManager)
			[keywordManager fileSetTo:currentImageFile];
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
	[self toggleVisible:mainVitaminSeeWindow];
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
	
	if([theMenuItem action] == @selector(openFolder:))
	{
		enable = mainWindowVisible && [currentImageFile isDir];
	}
	if([theMenuItem action] == @selector(closeWindow:) ||
	   [theMenuItem action] == @selector(referesh:))
	{
		enable = mainWindowVisible;
	}
	else if([theMenuItem action] == @selector(deleteFileClicked:))
	{
		// We can delete this file as long as we've selected a file.
		enable = mainWindowVisible && [[viewAsIconsController selectedFiles] count];
	}
	// View Menu
	else if ([theMenuItem action] == @selector(actualSize:))
	{
		enable = mainWindowVisible && [currentImageFile isImage] && 
			!(scaleProportionally && scaleRatio == 1.0);
	}
	else if([theMenuItem action] == @selector(zoomToFit:))
	{
		enable = mainWindowVisible && [currentImageFile isImage] && scaleProportionally;
	}
	else if ([theMenuItem action] == @selector(zoomIn:) ||
			 [theMenuItem action] == @selector(zoomOut:))
	{
		enable = mainWindowVisible && [currentImageFile isImage];
	}
	else if([theMenuItem action] == @selector(revealInFinder:))
	{
		enable = mainWindowVisible && [[viewAsIconsController selectedFiles] count];
	}
	else if([theMenuItem action] == @selector(viewInPreview:))
	{
		enable = mainWindowVisible && [currentImageFile isImage];
	}
	// Go Menu
    else if ([theMenuItem action] == @selector(goEnclosingFolder:))
    {
		// You can go up as long as there is a thing to go back on...
        enable = mainWindowVisible && [viewAsIconsController canGoEnclosingFolder];
    }
    else if ([theMenuItem action] == @selector(goBack:))
    {
        enable = mainWindowVisible && [pathManager canUndo];
    }
	else if ([theMenuItem action] == @selector(goForward:))
	{
		enable = mainWindowVisible && [pathManager canRedo];
	}
	else if ([theMenuItem action] == @selector(goToPicturesFolder:))
	{
		enable = [[NSHomeDirectory() stringByAppendingPathComponent:@"Pictures"] isDir];
	}
	else if ([theMenuItem action] == @selector(goToFolder:))
	{
		enable = mainWindowVisible;
	}
	
    return enable;
}

- (void)setCurrentFile:(NSString*)newCurrentFile
{
	[currentImageFile release];
	currentImageFile = newCurrentFile;
	[currentImageFile retain];
	
	// Okay, we don't know what kind of thing we have been passed, so let's
	BOOL isDir = [newCurrentFile isDir];
	if((newCurrentFile && isDir) || !currentImageFile)
		[fileSizeLabel setObjectValue:@"---"];
	else
		[fileSizeLabel setObjectValue:[NSNumber 
			numberWithInt:[newCurrentFile fileSize]]];
	
	if(![newCurrentFile isImage])
		[imageSizeLabel setStringValue:@"---"];
	
	// Alert all the plugins of the new file:
	NSEnumerator* e = [loadedCurrentFilePlugins objectEnumerator];
	id <CurrentFilePlugin> plugin;
	while(plugin = [e nextObject])
		[plugin fileSetTo:newCurrentFile];

	[self redraw];
}

-(void)preloadFile:(NSString*)file
{
	if([[[NSUserDefaults standardUserDefaults] objectForKey:@"PreloadImages"] boolValue])
		[imageTaskManager preloadImage:file];
}

-(void)redraw
{
	[imageTaskManager setSmoothing:[[[NSUserDefaults standardUserDefaults]
		objectForKey:@"SmoothingTag"] intValue]];
	[imageTaskManager setScaleProportionally:scaleProportionally];
	[imageTaskManager setScaleRatio:scaleRatio];
	[imageTaskManager setContentViewSize:[scrollView contentSize]];

	if(!currentImageFile)
		[imageViewer setImage:nil];	
	else
	{
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

// Redraw the window when the window resizes.
-(void)windowDidResize:(NSNotification*)notification
{
	[self redraw];
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
	
	// Set the correct cursor.
	if([image size].width > [scrollView contentSize].width ||
	   [image size].height > [scrollView contentSize].height)
		[(NSScrollView*)[imageViewer superview] setDocumentCursor:handCursor];
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
	[progressIndicator setHidden:NO];
	[progressIndicator startAnimation:self];
}

-(void)stopProgressIndicator
{
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
}

-(IBAction)showPreferences:(id)sender
{
	if (!prefs) {
        // Determine path to the sample preference panes
        
        prefs = [[SS_PrefsController alloc] initWithPanesSearchPath:
		 [[NSBundle mainBundle] builtInPlugInsPath] bundleExtension:@"cqvPref"];
        
        // Set which panes are included, and their order.
        [prefs setPanesOrder:[NSArray arrayWithObjects:@"General",
			@"Favorites", @"Keywords", @"Updating", 
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

@end
