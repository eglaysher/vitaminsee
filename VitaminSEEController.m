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
#import "NSView+Set_and_get.h"
#import "PluginLayer.h"
#import "SortManagerController.h"
#import "IconFamily.h"
#import "ImmutableToMutableTransformer.h"
#import "SS_PrefsController.h"
#import "KeywordNode.h"

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
*/

//////////////////////////////////////////////////////// WHAT NEEDS TO BE DONE:

/* THINGS TO ASK AT THE COCOA MEETING:
  * How to (properly) truncate the text in my NSCell...
    * Don't?
  * How to display the editing field in my NSCell so I can krunking get renaming
    working...
    * Integrated into inspector?
  * Computer/Macintosh HD/... ? How do I do this? Do I need to make my own
    internal VFSish system?
    *
  * Legality of using Apple icons? Modification? NO!
 */

/* NSString different function not pathComponenets. 
   The Mac OSX File System -[NSFileManager displayNameAtPath:]
 */

/* FIRST MILESTONE GOALS (Note that the milestones have gone apeshit...)
  * Work on making things feature complete.
  * Integrated Help
  * Icons for SortManager and KeywordManager in Preferences.
  * VitaminSEE icon.
  * Split ImageTaskManager into two threads: One for displaying and one for 
    preload/icons. This will help performance since it never goes above 50% CPU
    Utilization on my iBook.
*/

/**
  Non-required improvements that would be a good idea:
  * Prioritize thumbnail loading to currently visible files...
  * Fit to height/Fit to width
  */

/////////////////////////////////////////////////////////// POST CONTEST GOALS:

/* THIRD MILSTONE GOALS
 * Draging of the picture
 * Go to folder like in finder. (Use sheet/modal depending on whether main window
   is shown...)
 * See "openHandCursor" and "closedHandCursor"
 * Fullscreen mode.
 * Integrated help
 */

/* FOURTH MILESTONE GOALS
  * GIF/PNG keywords and comments.    
  * JPEG comments
  * Integrate into the [Computer name]/[Macintosh HD]/.../ hiearachy...
  * Transparent Zip/Rar support
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

+ (void)initialize 
{
	// Set up our custom NSValueTransformer
	[NSValueTransformer setValueTransformer:[[[ImmutableToMutableTransformer alloc] init] autorelease]
									forName:@"ImmutableToMutableTransformer"];
	
	// Set up this application's default preferences	
    NSMutableDictionary *defaultPrefs = [NSMutableDictionary dictionary];
	[defaultPrefs setObject:[NSHomeDirectory() stringByAppendingPathComponent:
		@"Pictures"] forKey:@"DefaultStartupPath"];
    
	// General preferences
	[defaultPrefs setObject:[NSNumber numberWithInt:3] forKey:@"SmoothingTag"];
	[defaultPrefs setObject:[NSNumber numberWithBool:YES] forKey:@"DisplayThumbnails"];
	[defaultPrefs setObject:[NSNumber numberWithBool:YES] forKey:@"GenerateThumbnails"];
	[defaultPrefs setObject:[NSNumber numberWithBool:NO] forKey:@"GenerateThumbnailsInArchives"];

	// Keyword preferences
	KeywordNode* node = [[[KeywordNode alloc] initWithParent:nil keyword:@"Keywords"] autorelease];
	NSData* emptyKeywordNode = [NSKeyedArchiver archivedDataWithRootObject:node];
	[defaultPrefs setObject:emptyKeywordNode forKey:@"KeywordTree"];
	
	// Default sort manager array
	NSArray* sortManagerPaths = [NSArray arrayWithObjects:
		[NSDictionary dictionaryWithObjectsAndKeys:@"Pictures", @"Name",
			[NSHomeDirectory() stringByAppendingPathComponent:@"Pictures"], @"Path", nil], 
		nil];
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
	id newClipView = [[SBCenteringClipView alloc] initWithFrame:[[scrollView contentView] frame]];
	[newClipView setBackgroundColor:[NSColor windowBackgroundColor]];
	[scrollView setContentView:(NSClipView*)newClipView];
	[newClipView release];
	[scrollView setDocumentView:docView];
	[docView release];
	
	[imageViewer setAnimates:YES];
	
	// Use our file size formatter for formating the "[image size]" text label
	FileSizeFormatter* fsFormatter = [[[FileSizeFormatter alloc] init] autorelease];
	[[fileSizeLabel cell] setFormatter:fsFormatter];
	
	// Set up the menu icons
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
	
	// 
	pathManager = [[NSUndoManager alloc] init];
	
	// Now we start work on thread communication.
	NSPort *port1 = [NSPort port];
	NSPort *port2 = [NSPort port];
	NSConnection* kitConnection = [[NSConnection alloc] 
		initWithReceivePort:port1 sendPort:port2];
	[kitConnection setRootObject:self];
	
	NSArray *portArray = [NSArray arrayWithObjects:port2, port1, nil];
	
	// Launch the other thread and tell it to connect back to us.
	imageTaskManager = [[ImageTaskManager alloc] initWithPortArray:portArray];
	
	// Now that we have our task manager, tell everybody to use it.
	[viewAsIconsController setImageTaskManager:imageTaskManager];
	
	// set our current directory 
	[self setCurrentDirectory:[[NSUserDefaults standardUserDefaults] 
		objectForKey:@"DefaultStartupPath"]
						 file:nil];		
}

-(void)dealloc
{
	[pathManager release];
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

- (void)setCurrentDirectory:(NSString*)newCurrentDirectory file:(NSString*)newCurrentFile
{	
	//
	if(newCurrentDirectory && currentDirectory && 
	   ![currentDirectory isEqual:newCurrentDirectory])
		[[pathManager prepareWithInvocationTarget:self]
			setCurrentDirectory:currentDirectory file:nil];
	
	// Clear the thumbnails being displayed.
	if(![newCurrentDirectory isEqualTo:currentDirectory])
		[imageTaskManager clearThumbnailQueue];
	
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
	
	// Now we figure out which view is currently in...view...and tell it to perform it's stuff
	// appropriatly...
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
}

-(IBAction)goForward:(id)sender
{
	[pathManager redo];
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

	[self setCurrentDirectory:[NSHomeDirectory() stringByAppendingPathComponent:@"Pictures"]
						 file:nil];
}

-(IBAction)goToFolder:(id)sender
{
	// fixme: stub.
	NSLog(@"Something happened.");
	
//	if(!gotoFolderSheet)
//		[NSBundle loadNibNamed:@"GoToFolderSheet" owner:self];
//	
//	[NSApp beginSheet:gotoFolderSheet
//	   modalForWindow:mainVitaminSeeWindow
//		modalDelegate:self
//	   didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:)
//		  contextInfo:nil];
}

//- (void)sheetDidEnd:(NSWindow*)sheet
//		 returnCode:(int)returnCode 
//		contextInfo:(void *)contextInfo
//{
//    [sheet orderOut:self];
//	
//}

-(NSWindowController*)sortManagerController
{
	if(!_sortManagerController)
	{
		NSString *bundlePath = [[[NSBundle mainBundle] builtInPlugInsPath]
			stringByAppendingPathComponent:@"SortManager.cqvPlugin"];
		NSBundle *windowBundle = [NSBundle bundleWithPath:bundlePath];
		
		if(windowBundle)
		{
			Class windowControllerClass = [windowBundle principalClass];
			if(windowControllerClass)
			{
				_sortManagerController = [[windowControllerClass alloc] init];
				[_sortManagerController setPluginLayer:self];
				
				// Take note that we've loaded the plugin.
				[loadedFilePlugins addObject:_sortManagerController];
			}
		}
	}
		
	return _sortManagerController;
}

-(NSWindowController*)keywordManagerController
{
	if(!_keywordManagerController)
	{
		NSString *bundlePath = [[[NSBundle mainBundle] builtInPlugInsPath]
			stringByAppendingPathComponent:@"KeywordManager.cqvPlugin"];
		NSBundle *windowBundle = [NSBundle bundleWithPath:bundlePath];
		
		if(windowBundle)
		{
			Class windowControllerClass = [windowBundle principalClass];
			if(windowControllerClass)
			{
				_keywordManagerController = [[windowControllerClass alloc] init];
				[_keywordManagerController setPluginLayer:self];

				// Set the current image file.
				[_keywordManagerController fileSetTo:currentImageFile];
				
				// Take note that we've loaded the plugin.
				[loadedFilePlugins addObject:_keywordManagerController];
			}
		}
	}
	
	return _keywordManagerController;
}

-(IBAction)toggleVitaminSee:(id)sender
{
	if([mainVitaminSeeWindow isVisible])
		[mainVitaminSeeWindow close];
	else
		[mainVitaminSeeWindow makeKeyAndOrderFront:self];
}

-(IBAction)toggleSortManager:(id)sender
{	
	if([[[self sortManagerController] window] isVisible])
		[[self sortManagerController] close];
	else
		[[self sortManagerController] showWindow:self];
}

-(IBAction)toggleKeywordManager:(id)sender
{
	if([[[self keywordManagerController] window] isVisible])
		[[self keywordManagerController] close];
	else
		[[self keywordManagerController] showWindow:self];
}

-(BOOL)validateMenuItem:(NSMenuItem *)theMenuItem
{
    BOOL enable = [self respondsToSelector:[theMenuItem action]]; //handle general case.
	BOOL mainWindowVisible = [mainVitaminSeeWindow isVisible];
	
	if([theMenuItem action] == @selector(openFolder:))
	{
		enable = mainWindowVisible && [currentImageFile isDir];
	}
	if([theMenuItem action] == @selector(closeWindow:))
	{
		enable = mainWindowVisible;
	}
	else if([theMenuItem action] == @selector(deleteFileClicked:))
	{
		// We can delete this file as long as we've selected a file.
		// fixme: this doesn't work...
		enable = mainWindowVisible && (currentImageFile != nil);
	}
	// View Menu
	else if ([theMenuItem action] == @selector(actualSize:) ||
			 [theMenuItem action] == @selector(zoomIn:) ||
			 [theMenuItem action] == @selector(zoomOut:) ||
			 [theMenuItem action] == @selector(zoomToFit:))
	{
		enable = mainWindowVisible && [currentImageFile isImage];
	}
	else if([theMenuItem action] == @selector(revealInFinder:))
	{
		enable = mainWindowVisible;
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
	if(newCurrentFile && isDir)
		[fileSizeLabel setObjectValue:@"---"];
	else
		[fileSizeLabel setObjectValue:[NSNumber 
			numberWithInt:[newCurrentFile fileSize]]];

	[imageTaskManager setScaleProportionally:scaleProportionally];
	[imageTaskManager setScaleRatio:scaleRatio];
	[imageTaskManager setContentViewSize:[scrollView contentSize]];
	
	[imageTaskManager displayImageWithPath:newCurrentFile];
	
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
	NSEnumerator* e = [filesToPreload objectEnumerator];
	NSString* path;
	while(path = [e nextObject])
		[imageTaskManager preloadImage:path];
}

-(void)redraw
{
	[imageTaskManager setSmoothing:[[[NSUserDefaults standardUserDefaults]
		objectForKey:@"SmoothingTag"] intValue]];
	[imageTaskManager setScaleProportionally:scaleProportionally];
	[imageTaskManager setScaleRatio:scaleRatio];
	[imageTaskManager setContentViewSize:[scrollView contentSize]];
	
	if([currentImageFile isImage])
		[imageTaskManager displayImageWithPath:currentImageFile];
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
	[self redraw];
}

// Callback function for ImageTaskManager. Gets called when an image is to be
// displayed in the window...
-(void)displayImage
{
	// Get the current image from the ImageTaskManager
	int x, y;
	float scale;
	NSImage* image = [imageTaskManager getCurrentImageWithWidth:&x height:&y scale:&scale];
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
	NSImage* thumbnail = [imageTaskManager getCurrentThumbnail];
	id cell = [imageTaskManager getCurrentThumbnailCell];
	
	[cell setIconImage:thumbnail];
	[viewAsIconsController updateCell:cell];
	
	// Release the current icon
	[thumbnail release];
}

// Progress indicator control
-(void)startProgressIndicator:(NSString*)statusText
{
	[progressIndicator setHidden:NO];
	[progressIndicator startAnimation:self];
	
	if(statusText)
	{
		[progressCurrentTask setHidden:NO];
		[progressCurrentTask setStringValue:statusText];
	}
}

-(void)stopProgressIndicator
{
	[progressIndicator stopAnimation:self];
	[progressIndicator setHidden:YES];
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

@end
