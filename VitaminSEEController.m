#import "VitaminSEEController.h"
#import "ToolbarDelegate.h"

//#import "FSNodeInfo.h"
//#import "FSBrowserCell.h"
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

@implementation VitaminSEEController

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

  * Comments (or yank it out!)
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

/// For Version 0.6
// * Redo left panel as loadable bundle with an NSTableView
//   * Requires a working plugin layer...
// * Finder notifications
// * Transparent archive support

// For Version 0.7
// * Create an image database feature
// * Add metadata for PNG and GIF

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
 * Image search (Loadable bundle)
 * Duplicate search (Loadable bundle)
 * Integrate into the [Computer name]/[Macintosh HD]/.../ hiearachy...
 * Transparent Zip/Rar support
 * Split *thumbnailing* off into it's own thread? (Image display/preload stays
   in it's own thread, instead of making image display in one and thumbnailing
   and preloading in the other...)
   * This causes problems with not enough CPU for both the thumbnailing/image
     loading...
 */

/* THIRD MILSTONE GOALS
 * Respond to finder notifications!
 * Draging of the picture
 * See "openHandCursor" and "closedHandCursor"
 * Fullscreen mode.
 * Make Go to folder modal when main window isn't open.
 */

/* FOURTH MILESTONE GOALS
  * GIF/PNG keywords and comments.    
  * JPEG comments
  * Change arrow key behaviour - scroll around in image if possible in NSScrollView
    and switch images
    * Julius says see "CDisplay" (Comics Viewer)
*/

/* POST 1.0 GOALS
  * Move almost EVERYTHING into their own component bundles for lazy loading...
    * Sort manager
    * Keyword manager
    * Including View as Icon view!
  * View as list view
  * View as browser view...
  * Duplicate detector
  * Image Search
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
	
	// Set up this application's default preferences	
    NSMutableDictionary *defaultPrefs = [NSMutableDictionary dictionary];
	[defaultPrefs setObject:[NSHomeDirectory() stringByAppendingPathComponent:
		@"Pictures"] forKey:@"DefaultStartupPath"];
    
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
	NSArray* sortManagerPaths = [NSArray arrayWithObjects:
		[NSDictionary dictionaryWithObjectsAndKeys:@"Pictures", @"Name",
			[NSHomeDirectory() stringByAppendingPathComponent:@"Pictures"], 
			@"Path", nil], nil];
	[defaultPrefs setObject:sortManagerPaths forKey:@"SortManagerPaths"];
	[defaultPrefs setObject:[NSNumber numberWithBool:YES] forKey:@"SortManagerInContextMenu"];
	
	[[NSUserDefaults standardUserDefaults] registerDefaults: defaultPrefs];
}

- (void)awakeFromNib
{
	// Set up the file viewer on the left
	[self setViewAsView:[viewAsIconsController view]];
	[viewAsIconsController awakeFromNib];
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
	
	// Set up the menu icons
	// CHNAGE THIS! It has to lookup and load the icons instead of just grabbing
	// them form the Application bundle!
	NSImage* img = [[NSWorkspace sharedWorkspace] iconForFile:NSHomeDirectory()];
	[img setSize:NSMakeSize(16, 16)];
	[homeFolderMenuItem setImage:img];

	img = [[NSWorkspace sharedWorkspace] iconForFile:
		[NSHomeDirectory() stringByAppendingPathComponent:@"Pictures"]];
	[img setSize:NSMakeSize(16, 16)];
	[pictureFolderMenuItem setImage:img];
	
	[self setupToolbar];
	[self zoomToFit:self];
	
	// Set our plugins to nil
	loadedFilePlugins = [[NSMutableArray alloc] init];
	_sortManagerController = nil;	
	
	// Use an Undo manager to manage moving back and forth.
	pathManager = [[NSUndoManager alloc] init];	
	
	// Launch the other thread and tell it to connect back to us.
	imageTaskManager = [[ImageTaskManager alloc] initWithController:self];
	thumbnailManager = [[ThumbnailManager alloc] initWithController:self];
	
	// Now that we have our task manager, tell everybody to use it.
	[viewAsIconsController setThumbnailManager:thumbnailManager];
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
	[self setCurrentDirectory:[[NSUserDefaults standardUserDefaults] 
		objectForKey:@"DefaultStartupPath"]
						 file:nil];
	[self stopProgressIndicator];
	[directoryDropdown setEnabled:YES];
	
	// Make the icon view the first responder since the previous enable
	// makes directoryDropdown FR.
	[viewAsIconsController makeFirstResponderTo:mainVitaminSeeWindow];
}

-(BOOL)application:(NSApplication*)theApplication openFile:(NSString*)filename
{	
	if([filename isImage])
	{
		// Show the window
		if(![mainVitaminSeeWindow isVisible])
			[self toggleVitaminSee:self];
		
		[self setCurrentDirectory:[filename stringByDeletingLastPathComponent] 
							 file:filename];
	}
	else if([filename isDir])
	{
		// Show the window
		if(![mainVitaminSeeWindow isVisible])
			[self toggleVitaminSee:self];
		
		[self setCurrentDirectory:filename file:nil];
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
	currentFileView = nextView;
}

- (void)setCurrentDirectory:(NSString*)newCurrentDirectory
					   file:(NSString*)newCurrentFile
{	
	[self startProgressIndicator];
	
	//
	if(newCurrentDirectory && currentDirectory && 
	   ![currentDirectory isEqual:newCurrentDirectory])
		[[pathManager prepareWithInvocationTarget:self]
			setCurrentDirectory:currentDirectory file:nil];
	
	// Clear the thumbnails being displayed.
	if(![newCurrentDirectory isEqualTo:currentDirectory])
		[thumbnailManager clearThumbnailQueue];
	
	// Set the current Directory
	[currentDirectory release];
	currentDirectory = [newCurrentDirectory stringByStandardizingPath];
	[currentDirectory retain];
	
	// Set the current paths components of the directory
	[currentDirectoryComponents release];
	currentDirectoryComponents = [newCurrentDirectory pathComponents];
	[currentDirectoryComponents retain];
	
	// Make an NSMenu with all the path components
	NSEnumerator* e = [currentDirectoryComponents reverseObjectEnumerator];
	NSString* currentComponent;
	NSMenu* newMenu = [[[NSMenu alloc] init] autorelease];
	NSMenuItem* newMenuItem;
	int currentTag = [currentDirectoryComponents count];
	while(currentComponent = [e nextObject]) {
		newMenuItem = [[[NSMenuItem alloc] initWithTitle:currentComponent
												  action:@selector(directoryMenuSelected:)
										   keyEquivalent:@""] autorelease];
		[newMenuItem setImage:[[NSString pathWithComponents:
			[currentDirectoryComponents subarrayWithRange:NSMakeRange(0, currentTag)]] 
			iconImageOfSize:NSMakeSize(16,16)]];
		[newMenuItem setTag:currentTag];
		currentTag--;
		[newMenu addItem:newMenuItem];
	}

	// Set this menu as the pull down...
	[directoryDropdown setMenu:newMenu];
	
	// Now we figure out which view is currently in...view...and tell it to 
	// perform it's stuff appropriatly...
	if(currentFileView == [viewAsIconsController view])
		[viewAsIconsController setCurrentDirectory:newCurrentDirectory];
	
	if(newCurrentFile)
	{
		[self setCurrentFile:newCurrentFile];
		[viewAsIconsController selectFile:newCurrentFile];
	}
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
	[viewAsIconsController setCurrentDirectory:currentDirectory];
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
	int count = [currentDirectoryComponents count] - 1;
	NSString* curDirCopy = [currentDirectory retain];
	[self setCurrentDirectory:[NSString pathWithComponents:
		[currentDirectoryComponents subarrayWithRange:NSMakeRange(0, count)]]
						 file:curDirCopy];
	[curDirCopy release];
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
	[self setCurrentDirectory:NSHomeDirectory() file:nil];
}

-(IBAction)goToPicturesFolder:(id)sender
{
	if(![mainVitaminSeeWindow isVisible])
		[self toggleVitaminSee:self];

	[self setCurrentDirectory:[NSHomeDirectory() 
		stringByAppendingPathComponent:@"Pictures"] file:nil];
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
		// Valid directory! Let's set it!
		[self setCurrentDirectory:done file:nil];
	}
	else
	{
		// Beep at the user...
		AlertSoundPlay();
	}
}
	
-(id)loadComponentFromBundle:(NSString*)path
{
	NSString *bundlePath = [[[NSBundle mainBundle] builtInPlugInsPath]
			stringByAppendingPathComponent:path];
	NSBundle *windowBundle = [NSBundle bundleWithPath:bundlePath];	
	id component;

	if(windowBundle)
	{
		Class windowControllerClass = [windowBundle principalClass];
		if(windowControllerClass)
			component = [[windowControllerClass alloc] init];
	}
	
	return component;
}
	
-(id)sortManagerController
{
	if(!_sortManagerController)
	{
		id loaded = [self loadComponentFromBundle:@"SortManager.cqvPlugin"];
		if(loaded)
		{
			_sortManagerController = loaded;
			[_sortManagerController setPluginLayer:self];
			[loadedFilePlugins addObject:_sortManagerController];
		}		
	}
		
	return _sortManagerController;
}

-(id)keywordManagerController
{
	if(!_keywordManagerController)
	{
		id loaded = [self loadComponentFromBundle:@"KeywordManager.cqvPlugin"];
		if(loaded)
		{
			_keywordManagerController = loaded;
			[_keywordManagerController setPluginLayer:self];
			[_keywordManagerController fileSetTo:currentImageFile];
			
			[loadedFilePlugins addObject:_keywordManagerController];			
		}
	}
	
	return _keywordManagerController;
}

-(id)gotoFolderController
{
	if(!_gotoFolderController)
	{
		id loaded = [self loadComponentFromBundle:@"GotoFolderSheet.bundle"];
		if(loaded)
			_gotoFolderController = loaded;
	}
	
	return _gotoFolderController;	
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
		// fixme: this doesn't work...
		enable = mainWindowVisible && [viewAsIconsController canDelete];
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
		enable = mainWindowVisible && [viewAsIconsController canDelete];
	}
	else if([theMenuItem action] == @selector(viewInPreview:))
	{
		enable = mainWindowVisible && [currentImageFile isImage];
	}
	// Go Menu
    else if ([theMenuItem action] == @selector(goEnclosingFolder:))
    {
		// You can go up as long as there is a thing to go back on...
        enable = mainWindowVisible && [currentDirectoryComponents count] > 1;
    }
    else if ([theMenuItem action] == @selector(goBack:))
    {
        enable = mainWindowVisible && [pathManager canUndo];
    }
	else if ([theMenuItem action] == @selector(goForward:))
	{
		enable = mainWindowVisible && [pathManager canRedo];
	}
	else if ([theMenuItem action] == @selector(goToFolder:))
	{
		enable = mainWindowVisible;
	}
	
    return enable;
}

-(void)directoryMenuSelected:(id)sender
{
	NSString* newDirectory = [NSString pathWithComponents:
		[currentDirectoryComponents subarrayWithRange:NSMakeRange(0,[sender tag])]];
	NSString* directoryToSelect = nil;
	if([sender tag] < [currentDirectoryComponents count])
		directoryToSelect = [NSString pathWithComponents:
			[currentDirectoryComponents subarrayWithRange:NSMakeRange(0,[sender tag]+1)]];
	[self setCurrentDirectory:newDirectory file:directoryToSelect];
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
	NSEnumerator* e = [loadedFilePlugins objectEnumerator];
	id <FileManagerPlugin> plugin;
	while(plugin = [e nextObject])
		[plugin fileSetTo:newCurrentFile];

	[self redraw];
}

-(void)preloadFiles:(NSArray*)filesToPreload
{
	if([[[NSUserDefaults standardUserDefaults] objectForKey:@"PreloadImages"] boolValue])
	{
		NSEnumerator* e = [filesToPreload objectEnumerator];
		NSString* path;
		while(path = [e nextObject])
			[imageTaskManager preloadImage:path];
	}
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
//	id cell = [thumbnailManager getCurrentThumbnailCell];
	NSString* path = [thumbnailManager getCurrentPath];

	[viewAsIconsController setThumbnail:thumbnail forFile:path];
	
//	[cell setIconImage:thumbnail];
//	[viewAsIconsController updateCell:cell];
	
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
			@"Sort Manager", @"Keywords", @"Updating", 
			@"A Non-Existent Preference Pane", nil]];
    }
    
    // Show the preferences window.
    [prefs showPreferencesWindow];
}

-(IBAction)deleteFileClicked:(id)sender
{
	[self deleteThisFile];
}

-(IBAction)showGPL:(id)sender
{
	[[NSWorkspace sharedWorkspace] openFile:[[NSBundle mainBundle] 
		pathForResource:@"GPL"
				 ofType:@"txt"]];
}

@end
