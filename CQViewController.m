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
 * More speed hacks!?
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
	[defaultPrefs setObject:@"/Users/elliot/Pictures/Wallpaper/Nature Wallpaper"
					 forKey:@"DefaultStartupPath"];
	//
	//@"/Users/elliot/Pictures/4chan/Straight Up Ero"  
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
	
	imageTaskManager = [[ImageTaskManager alloc] init];
	
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

-(BOOL)validateMenuItem:(NSMenuItem *)theMenuItem
{
    BOOL enable = [self respondsToSelector:[theMenuItem action]]; //handle general case.
	
    if ([theMenuItem action] == @selector(goEnclosingFolder:))
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
	// Okay, we don't know what kind of thing we have been passed, so let's
	BOOL isDir = [newCurrentFile isDir];
	if(isDir)
		[fileSizeLabel setObjectValue:@"---"];
	else
		[fileSizeLabel setObjectValue:[NSNumber 
			numberWithInt:[newCurrentFile fileSize]]];

	// Release the old image...
	[currentImageRep release];
	
	if([newCurrentFile isImage])
	{
		// This item is an image. Let's load it.
		currentImageRep = [[imageTaskManager getImage:newCurrentFile] retain];
		
		// Set the label to the image size.
		int x = [currentImageRep pixelsWide];
		int y = [currentImageRep pixelsHigh];
		[imageSizeLabel setStringValue:[NSString 
			stringWithFormat:@"%i x %i", x, y]];
	}
	else
	{
		// Send preload messages first (since next line doesn't access the
		// cache.)
		currentImageRep = [[[newCurrentFile iconImageOfSize:NSMakeSize(128,128)]
			bestRepresentationForDevice:nil] retain];

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
	// Size of picture
	int imageX = [currentImageRep pixelsWide];
	int imageY = [currentImageRep pixelsHigh];
	NSSize contentSize = [scrollView contentSize];
	int boxWidth = contentSize.width;
	int boxHeight = contentSize.height;
	int displayX, displayY;
	BOOL canGetAwayWithQuickRender = NO;
	
	if(scaleProportionally == YES)
	{
		// Set the size of the image to the size of the image scaled by our 
		// ratio and then tell the imageViewer to scale it to that size.
		displayX = imageX * scaleRatio;
		displayY = imageY * scaleRatio;
		if(displayX < boxWidth && displayY < boxHeight)
			canGetAwayWithQuickRender = YES; 
	}
	else
	{
		// Set the size of the display version of the image so that it fits 
		// within the constraints of the NSScaleView that contains this 
		// NSImageView.
		float heightRatio = buildRatio(boxHeight, imageY);
		float widthRatio = buildRatio(boxWidth, imageX);
		if(imageX <= boxWidth && imageY <= boxHeight)
		{
			// The image is smaller then the conrentSize and we should just
			// use the size of the image.
			displayX = imageX;
			displayY = imageY;
			canGetAwayWithQuickRender = YES;
		}
		else
		{
			// The image needs to be scaled to fit in the box. Go through the
			// two possible ratios in terms of biggest first and check to
			// see if they work. We sort an array of the two values so we make
			// sure we aren't scaling smaller then what can be displayed on the
			// screen
			canGetAwayWithQuickRender = NO;
			
			NSMutableArray* ratios = [NSMutableArray arrayWithObjects:[NSNumber 
				numberWithFloat:heightRatio], [NSNumber numberWithFloat:widthRatio], nil];
			[ratios sortUsingSelector:@selector(compare:)];
			NSEnumerator* e = [ratios reverseObjectEnumerator];
			NSNumber* num;
			while(num = [e nextObject])
			{
				float ratio = [num floatValue];
				if((int)(imageX * ratio) <= boxWidth &&
				   (int)(imageY * ratio) <= boxHeight)
				{
					// We've found the ratio to use. Get out of this loop...
					displayX = imageX * ratio;
					displayY = imageY * ratio;
					break;
				}
			}
		}
	}
	
	if(imageRepIsAnimated(currentImageRep) || canGetAwayWithQuickRender)
	{
		// Draw the image by just making an NSImage from the imageRep. This is
		// done when the image will fit in the viewport, or when we are 
		// rendering an animated GIF.
		NSImageRep* imageRep = [[currentImageRep copy] autorelease];
		NSImage* image = [[[NSImage alloc] init] autorelease];
		[image addRepresentation:imageRep];
		
		// Scale it anyway, because some pictures LIE about their size.
		[image setScalesWhenResized:YES];
		[image setSize:NSMakeSize(displayX, displayY)];

		[imageViewer setFrameSize:NSMakeSize(displayX, displayY)];
		[imageViewer setAnimates:YES];
		[imageViewer setImage:image];
	}
	else
	{
		// Draw the image onto a new NSImage using smooth scaling. This is done
		// whenever the image isn't animated so that the picture will have 
		// some antialiasin lovin' applied to it.
		[imageViewer setFrameSize:NSMakeSize(displayX, displayY)];
		NSImage* newImage = [[[NSImage alloc] initWithSize:NSMakeSize(displayX,
			displayY)] autorelease];
		[newImage lockFocus];
		{
			[[NSGraphicsContext currentContext] 
				setImageInterpolation:NSImageInterpolationHigh];
			[currentImageRep drawInRect:NSMakeRect(0,0,displayX,displayY)];
		}
		[newImage unlockFocus];
		
		// set our image.
		[imageViewer setImage:newImage];
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

@end
