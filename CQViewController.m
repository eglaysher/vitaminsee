#import "CQViewController.h"
#import "ToolbarDelegate.h"

//#import "FSNodeInfo.h"
//#import "FSBrowserCell.h"
#import "FileSizeFormatter.h"
#import "SBCenteringClipView.h"
#import "ViewIconViewController.h"
#import "ImageTaskManager.h"
#import "Util.h"
#import "NSString+FileTasks.h"
#import "NSView+Set_and_get.h"

@implementation CQViewController

/*
 TODO: 
 * Rework FSBrowserCell's 
 - (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView;
	for my own purposes
 * Find out the legality of using Apple icons...
 * Implement the backHistory/forwardHistory!
 * All kinds of file operations.
   * Delete files
   * et cetera! 
 * Complete sort manager (a la GQView)
 * Get drag on image for moving around an image...
 */

// Set up this application's default preferences
+ (void)initialize 
{
    NSMutableDictionary *defaultPrefs = [NSMutableDictionary dictionary];
	[defaultPrefs setObject:[NSHomeDirectory() stringByAppendingPathComponent:
		@"Pictures/Wallpaper/Nature Wallpaper"] forKey:@"DefaultStartupPath"];
    
	[[NSUserDefaults standardUserDefaults] registerDefaults: defaultPrefs];
}

- (void)awakeFromNib
{
	[self setViewAsView:[viewAsIconsController view]];
	[viewerWindow setInitialFirstResponder:[viewAsIconsController view]];	
	
	// Now set up the scroll view...
	id docView = [[scrollView documentView] retain];
	id newClipView = [[SBCenteringClipView alloc] initWithFrame:[[scrollView contentView] frame]];
	[newClipView setBackgroundColor:[NSColor windowBackgroundColor]];
	[scrollView setContentView:(NSClipView*)newClipView];
	[newClipView release];
	[scrollView setDocumentView:docView];
	[docView release];
	
	[imageViewer setAnimates:YES];
	
	FileSizeFormatter* fsFormatter = [[[FileSizeFormatter alloc] init] autorelease];
	[[fileSizeLabel cell] setFormatter:fsFormatter];
	
	[self setupToolbar];
	scaleProportionally = NO;

	// First, we'll need to setup a network connection between ourself and our
	// worker thread...
	NSPort *port1 = [NSPort port];
	NSPort *port2 = [NSPort port];
	NSConnection* kitConnection = [[NSConnection alloc] 
		initWithReceivePort:port1 sendPort:port2];
	[kitConnection setRootObject:self];
	
	NSArray *portArray = [NSArray arrayWithObjects:port2, port1, nil];
	
	// Launch the other thread and tell it to connect back to us.
	imageTaskManager = [[ImageTaskManager alloc] initWithPortArray:portArray];
	
	[self setCurrentDirectory:[[NSUserDefaults standardUserDefaults] 
		objectForKey:@"DefaultStartupPath"]];		
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
{
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
}

-(IBAction)goEnclosingFolder:(id)sender
{
	int count = [currentDirectoryComponents count] - 1;
	[self setCurrentDirectory:[NSString pathWithComponents:
		[currentDirectoryComponents subarrayWithRange:NSMakeRange(0, count)]]];
}

-(IBAction)goBack:(id)sender
{
	
}

-(IBAction)goForward:(id)sender
{
	
}

-(IBAction)deleteThisFile:(id)sender
{
	NSString* fileToDelete = currentImageFile;
	
	// We need the next file after this so we have something to select after
	// we delete this file.
	NSArray* directoryContents = [[NSFileManager defaultManager] 
			directoryContentsAtPath:currentDirectory];
	int numberOfContents = [directoryContents count];
	NSEnumerator* dirEnum = [directoryContents objectEnumerator];
	NSString* nextFile;
	NSString* nextFileWithFullPath;
	while(nextFile = [dirEnum nextObject])
	{
		nextFileWithFullPath = [nextFile fileWithPath:currentDirectory];
		if([nextFileWithFullPath isEqual:currentImageFile])
		{
			// fixme: I need to handle the case with the last file.
			nextFile = [[dirEnum nextObject] fileWithPath:currentDirectory];
			break;
		}
	}
	// fixme: I don't handle the case where I have the last file. Menu needs disablement...
	if(numberOfContents == 1)
		nextFile = nil;

	// We move the current file to the trash.
	int tag;
	[[NSWorkspace sharedWorkspace] performFileOperation:NSWorkspaceRecycleOperation
												 source:currentDirectory
											destination:@""
												  files:[NSArray arrayWithObject:[currentImageFile lastPathComponent]]
													tag:&tag];

	[viewAsIconsController removeFileFromList:currentImageFile];
	
	if(nextFile)
	{
		[viewAsIconsController selectFile:nextFile];
	
		// Finally, we set the file to the next file so we display something
		[self setCurrentFile:nextFile];
	}
}

-(BOOL)validateMenuItem:(NSMenuItem *)theMenuItem
{
    BOOL enable = [self respondsToSelector:[theMenuItem action]]; //handle general case.
	
	if([theMenuItem action] == @selector(deleteThisFile:))
	{
		enable = currentImageFile != nil;
	}
	// GO FOLDER
    else if ([theMenuItem action] == @selector(goEnclosingFolder:))
    {
		// You can go up as long as there is a thing to go back on...
        enable = [currentDirectoryComponents count] > 1;
    }
    else if ([theMenuItem action] == @selector(goBack:))
    {
        enable = [backHistory count] > 0;
    }
	else if ([theMenuItem action] == @selector(goForward:))
	{
		enable = [forwardHistory count] > 0;
	}
	
    return enable;
}

-(void)directoryMenuSelected:(id)sender
{
	// Stub...
	NSString* newDirectory = [NSString pathWithComponents:
		[currentDirectoryComponents subarrayWithRange:NSMakeRange(0,[sender tag])]];
	[self setCurrentDirectory:newDirectory];
}

- (void)setCurrentFile:(NSString*)newCurrentFile
{
	currentImageFile = newCurrentFile;
	[currentImageFile retain];
	
	// Okay, we don't know what kind of thing we have been passed, so let's
	BOOL isDir = [newCurrentFile isDir];
	if(isDir)
		[fileSizeLabel setObjectValue:@"---"];
	else
		[fileSizeLabel setObjectValue:[NSNumber 
			numberWithInt:[newCurrentFile fileSize]]];

	// Release the old image...
//	[currentImageRep release];
	
	if([newCurrentFile isImage])
	{
		[imageTaskManager setScaleProportionally:scaleProportionally];
		[imageTaskManager setScaleRatio:scaleRatio];
		[imageTaskManager setContentViewSize:[scrollView contentSize]];
		
		[imageTaskManager displayImageWithPath:newCurrentFile];
	}
	else
	{
		// Send preload messages first (since next line doesn't access the
		// cache.)
//		currentImageRep = [[[newCurrentFile iconImageOfSize:NSMakeSize(128,128)]
//			bestRepresentationForDevice:nil] retain];

		// Set the label to "---"
		[imageSizeLabel setStringValue:@"---"];
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
	[imageTaskManager setScaleProportionally:scaleProportionally];
	[imageTaskManager setScaleRatio:scaleRatio];
	[imageTaskManager setContentViewSize:[scrollView contentSize]];
//	NSLog(@"CurrentImageFile: %@", currentImageFile);
	
	if([currentImageFile isImage])
	{
		[imageTaskManager displayImageWithPath:currentImageFile];
	}
	else
	{
//		[imageViewer setImage:[[currentImageFile iconImageOfSize:NSMakeSize(128,128)]
//			bestRepresentationForDevice:nil]];
	}
}

- (IBAction)scaleView100Pressed:(id)sender
{
	// Set our scale ratio to 1.0.
	scaleProportionally = YES;
	scaleRatio = 1.0;
	[scaleSlider setFloatValue:1.0];
	[self redraw];
}

// Method set the current view to proporotional scaling
- (IBAction)scaleViewPPressed:(id)sender
{
	scaleProportionally = NO;
	[self redraw];
}

// Called whenever the slider in ScaleView is moved. Resizes the image
- (IBAction)scaleViewSliderMoved:(id)sender
{
	scaleProportionally = YES;
	scaleRatio = [sender floatValue];
	[self redraw];
}

// Redraw the window when the window resizes.
-(void)windowDidResize:(NSNotification*)notification
{
	[self redraw];
}

-(void)splitViewDidResizeSubviews:(NSNotification*)notification
{
	[self redraw];
}

-(void)displayImage
{
	// Get a copy of the current display image from the ImageTaskManager
	NSImage* image = [imageTaskManager getCurrentImage];
//	NSLog(@"Image is %@", image);
//	NSLog(@"Image is proxy: %d", [image isProxy]);
//	NSLog(@"Main thread got a display image command! Image is %@", image);
	[imageViewer setImage:image];
	[imageViewer setFrameSize:[image size]];
	int x = [image size].width;
	int y = [image size].height;
	[imageSizeLabel setStringValue:[NSString stringWithFormat:@"%i x %i", 
		x, y]];
}



@end
