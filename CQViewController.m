#import "CQViewController.h"
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

@implementation CQViewController

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

/*
   NSString different function not pathComponenets.
 
   The Mac OSX File System -[NSFileManager displayNameAtPath:]
 
    VITAMIN SEE
 */

/* FIRST MILESTONE GOALS (Note that the milestones have gone apeshit...)

  * Comments (or yank it out!)
  * Cmd-O opens == double click.
  * Disable comments on things we can't comment on.
  * Icons for VitaminSee
  * Work on making things feature complete.
  * Validate menu items
  * Integrated Help
*/

/**
  Non-required improvements that would be a good idea:
  * Prioritize thumbnail loading to currently visible files...
  * Fit to height/Fit to width
  */

/////////////////////////////////////////////////////////// POST CONTEST GOALS:

/* THIRD MILSTONE GOALS
 * Draging of the picture
 * See "openHandCursor" and "closedHandCursor"
 * Fullscreen
 * Integrated help
 */

/* FOURTH MILESTONE GOALS
  * GIF/PNG keywords and comments.    
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
		@"Pictures/Wallpaper/Nature Wallpaper"] forKey:@"DefaultStartupPath"];
    
	// General preferences
	[defaultPrefs setObject:[NSNumber numberWithInt:3] forKey:@"SmoothingTag"];
	[defaultPrefs setObject:[NSNumber numberWithBool:YES] forKey:@"DisplayThumbnails"];
	[defaultPrefs setObject:[NSNumber numberWithBool:YES] forKey:@"GenerateThumbnails"];
	[defaultPrefs setObject:[NSNumber numberWithBool:NO] forKey:@"GenerateThumbnailsInArchives"];

	// Keyword preferences
	KeywordNode* node = [[[KeywordNode alloc] initWithParent:nil keyword:@"Keywords"] autorelease];
	[node addChild:[[[KeywordNode alloc] initWithParent:node keyword:@"Anime"] autorelease]];
	[node addChild:[[[KeywordNode alloc] initWithParent:node keyword:@"Blogs"] autorelease]];
	NSData* emptyKeywordNode = [NSKeyedArchiver archivedDataWithRootObject:node];
	[defaultPrefs setObject:emptyKeywordNode forKey:@"KeywordTree"];
	
	// Default sort manager array
	NSArray* sortManagerPaths = [NSArray arrayWithObjects:
		[NSDictionary dictionaryWithObjectsAndKeys:@"Pictures", @"Name",
			[NSHomeDirectory() stringByAppendingPathComponent:@"Pictures"], @"Path", nil], 
		[NSDictionary dictionaryWithObjectsAndKeys:@"Wallpaper", @"Name",
			[NSHomeDirectory() stringByAppendingPathComponent:@"Pictures/Wallpaper"], @"Path", nil], 
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
	
	sortManagerVisible = false;
	keyworManagerVisible = false;
	mainWindowVisible = true;
	
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

-(IBAction)closeWindow:(id)sender
{
	mainWindowVisible = false;
	[mainVitaminSeeWindow close];
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
	if(!mainWindowVisible)
		[self toggleVitaminSee:self];
	[self setCurrentDirectory:NSHomeDirectory() file:nil];
}

-(IBAction)goToPicturesFolder:(id)sender
{
	if(!mainWindowVisible)
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
		NSLog(@"Looking for bundle");
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
		NSLog(@"Looking for bundle");
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
	if(mainWindowVisible)
	{
		[mainVitaminSeeWindow close];
		mainWindowVisible = false;
	}
	else
	{
		[mainVitaminSeeWindow makeKeyAndOrderFront:self];
		mainWindowVisible = true;
	}
//showWindow:self];
}

-(IBAction)toggleSortManager:(id)sender
{	
	if(sortManagerVisible)
	{
		[[self sortManagerController] close];
		sortManagerVisible = false;
	}
	else
	{
		[[self sortManagerController] showWindow:self];
		sortManagerVisible = true;
	}
}

-(IBAction)toggleKeywordManager:(id)sender
{
	if(keyworManagerVisible)
	{
		[[self keywordManagerController] close];
		keyworManagerVisible = false;
	}
	else
	{
		[[self keywordManagerController] showWindow:self];
		keyworManagerVisible = true;
	}
}

-(BOOL)validateMenuItem:(NSMenuItem *)theMenuItem
{
    BOOL enable = [self respondsToSelector:[theMenuItem action]]; //handle general case.
	
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
	// GO FOLDER
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
	
//	NSLog(@"Setting to %@", newCurrentFile);
	
	// Okay, we don't know what kind of thing we have been passed, so let's
	BOOL isDir = [newCurrentFile isDir];
	if(newCurrentFile && isDir)
		[fileSizeLabel setObjectValue:@"---"];
	else
		[fileSizeLabel setObjectValue:[NSNumber 
			numberWithInt:[newCurrentFile fileSize]]];
	
	if([newCurrentFile isImage])
	{
		[imageTaskManager setScaleProportionally:scaleProportionally];
		[imageTaskManager setScaleRatio:scaleRatio];
		[imageTaskManager setContentViewSize:[scrollView contentSize]];
		
		[imageTaskManager displayImageWithPath:newCurrentFile];
	}
	else
	{
//		NSLog(@"Not displaying %@", newCurrentFile);
		// Set the label to "---" since this isn't an image...
		[imageSizeLabel setStringValue:@"---"];
	}
	
	// Alert all the plugins of the new file:
	NSEnumerator* e = [loadedFilePlugins objectEnumerator];
	id <FileManagerPlugin> plugin;
	while(plugin = [e nextObject])
	{
		[plugin fileSetTo:newCurrentFile];
	}

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

-(void)zoomIn:(id)sender
{
	scaleProportionally = YES;
	scaleRatio = scaleRatio + 0.10f;
	[self redraw];
}

-(void)zoomOut:(id)sender
{
	scaleProportionally = YES;
	scaleRatio = scaleRatio - 0.10;
	[self redraw];
}

-(void)zoomToFit:(id)sender
{
	scaleProportionally = NO;
	scaleRatio = 1.0;
	[self redraw];
}

-(void)actualSize:(id)sender
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
