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
#import "FileOperations.h"
#import "SortManagerController.h"
#import "IconFamily.h"
@implementation CQViewController

/*
 TODO: 
 * Rework FSBrowserCell's 
 - (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView;
	for my own purposes
 * Keywords
 * Find out the legality of using Apple icons...
 * Implement the backHistory/forwardHistory!
 * All kinds of file operations.
   * Rename files (this is proving to be kind of dificult!) (Done with delete/copy/etc)
 * Complete preferences for sort manager (the way GQView does it violates HIG)
 * Get drag on image for moving around an image...
 * Modify IconFamily to have a black line around the image...
 * Zoom is still screwing up in some places...
 * Integrate into the [Computer name]/[Macintosh HD]/.../ hiearachy...
 */

// Set up this application's default preferences
+ (void)initialize 
{
    NSMutableDictionary *defaultPrefs = [NSMutableDictionary dictionary];
	[defaultPrefs setObject:[NSHomeDirectory() stringByAppendingPathComponent:
		@"Pictures/Wallpaper/Nature Wallpaper"] forKey:@"DefaultStartupPath"];
    
	// Default sort manager array
	NSArray* sortManagerPaths = [NSArray arrayWithObjects:
		[NSDictionary dictionaryWithObjectsAndKeys:@"Pictures", @"Name",
			[NSHomeDirectory() stringByAppendingPathComponent:@"Pictures"], @"Path", nil], 
		[NSDictionary dictionaryWithObjectsAndKeys:@"4chan", @"Name",
			[NSHomeDirectory() stringByAppendingPathComponent:@"4chan"], @"Path", nil], 
		[NSDictionary dictionaryWithObjectsAndKeys:@"Wallpaper", @"Name",
			[NSHomeDirectory() stringByAppendingPathComponent:@"Pictures/Wallpaper"], @"Path", nil], 
		nil];
	[defaultPrefs setObject:sortManagerPaths forKey:@"SortManagerPaths"];
		
	[[NSUserDefaults standardUserDefaults] registerDefaults: defaultPrefs];
}

- (void)awakeFromNib
{
	// Set up the file viewer on the left
	[self setViewAsView:[viewAsIconsController view]];
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
	
	[self setupToolbar];
	[self zoomToFit:self];
	
	// 
	
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

-(void)moveThisFile:(NSString*)destination
{
	if(![destination isEqual:currentDirectory])
	{
		NSString* nextFile = [viewAsIconsController nameOfNextFile];
		[self moveFile:currentImageFile to:destination];
		[viewAsIconsController removeFileFromList:currentImageFile];
		[viewAsIconsController selectFile:nextFile];
		
		[self setCurrentFile:nextFile];
	}
}

-(void)copyThisFile:(NSString*)destination
{
	if(![destination isEqual:currentDirectory])
		[self copyFile:currentImageFile to:destination];
}

-(IBAction)deleteThisFile:(id)sender
{
	// Delete the current file...
	[self deleteFile:currentImageFile];

	// fixme: Functionate/refactor this.
	NSString* nextFile = [viewAsIconsController nameOfNextFile];
	[viewAsIconsController removeFileFromList:currentImageFile];
	[viewAsIconsController selectFile:nextFile];
	
	[self setCurrentFile:nextFile];
}

-(IBAction)showSortManager:(id)sender
{
	[sortManagerController showWindow:self];
}

-(BOOL)validateMenuItem:(NSMenuItem *)theMenuItem
{
    BOOL enable = [self respondsToSelector:[theMenuItem action]]; //handle general case.
	
	if([theMenuItem action] == @selector(deleteThisFile:))
	{
		// We can delete this file as long as we've selected a file.
		// fixme: this doesn't work...
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
	NSString* newDirectory = [NSString pathWithComponents:
		[currentDirectoryComponents subarrayWithRange:NSMakeRange(0,[sender tag])]];
	[self setCurrentDirectory:newDirectory];
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
		// Set the label to "---" since this isn't an image...
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
	
	if([currentImageFile isImage])
		[imageTaskManager displayImageWithPath:currentImageFile];
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

-(void)zoomIn:(id)sender
{
	scaleProportionally = YES;
	NSLog(@"ScaleRatio: %f Sum: %f", scaleRatio, scaleRatio + 0.10f);
	scaleRatio = scaleRatio + 0.10f;
	NSLog(@"Sum %f", scaleRatio);
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
	NSImage* image = [imageTaskManager getCurrentImageWithWidth:&x height:&y];
	[imageViewer setImage:image];
	[imageViewer setFrameSize:[image size]];
	
	if(!scaleProportionally)
		scaleRatio = min(buildRatio([image size].width, x), buildRatio([image size].height, y));

	[imageSizeLabel setStringValue:[NSString stringWithFormat:@"%i x %i", 
		x, y]];
}

-(void)setIcon
{
	NSImage* thumbnail = [imageTaskManager getCurrentThumbnail];
	id cell = [imageTaskManager getCurrentThumbnailCell];
	
	[cell setIconImage:thumbnail];
	[viewAsIconsController updateCell:cell];
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

@end
