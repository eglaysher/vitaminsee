#import "CQViewController.h"
#import "ToolbarDelegate.h"

#import "FSNodeInfo.h"
#import "FSBrowserCell.h"
#import "FileSizeFormatter.h"
#import "SBCenteringClipView.h"

#import "Util.h"

@implementation CQViewController

/*
 TODO: 
 * Rework FSBrowserCell's 
 - (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView;
	for my own purposes
 * Make the image resize in proportional mode when window resizes...
 */

// Set up this application's default preferences
+ (void)initialize 
{
    NSMutableDictionary *defaultPrefs = [NSMutableDictionary dictionary];
	[defaultPrefs setObject:@"/Users/elliot/Pictures/4chan/Straight Up Ero"  
					 forKey:@"DefaultStartupPath"];
	//@"/Users/elliot/Pictures/" 
    [[NSUserDefaults standardUserDefaults] registerDefaults: defaultPrefs];
}

- (void)awakeFromNib
{
	// Set the browser up for display...
    [browser setTarget: self];
    [browser setAction: @selector(browserSingleClick:)];
    [browser setDoubleAction: @selector(browserDoubleClick:)];
	[browser setCellClass: [FSBrowserCell class]];
	[browser setMaxVisibleColumns:1];
	[browser setPath:[[NSUserDefaults standardUserDefaults] 
			objectForKey:@"DefaultStartupPath"]];
	
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
}


// ============================================================================
//                           BROWSER METHODS
// ============================================================================

-(IBAction)browserSingleClick:(id)browser {
    NSImage *inspectorImage = nil;
    
    if ([[browser selectedCells] count]==1) {
		// We have a single item selected
        NSString *nodePath = [browser path];
        FSNodeInfo *fsNode = [FSNodeInfo nodeWithParent:nil 
										 atRelativePath:nodePath];
        
		id manager = [NSFileManager defaultManager];
		NSDictionary *fattrs = [manager fileAttributesAtPath:nodePath
												traverseLink:YES];
		
		// First, set the file size label.
		BOOL isDir;
		[manager fileExistsAtPath:[fsNode absolutePath] isDirectory:&isDir];
		if(isDir)
			[fileSizeLabel setObjectValue:@"---"];
		else
			[fileSizeLabel setObjectValue:[fattrs objectForKey:NSFileSize]];
		
		// Release the old image...
		[currentImageRep release];
		
		if([fsNode isImage])
		{
			// This item is an image. Let's load it.
			currentImageRep = [[NSImageRep imageRepWithContentsOfFile:[fsNode 
				absolutePath]] retain];
			
			// Set the label to the image size.
			int x = [currentImageRep pixelsWide];
			int y = [currentImageRep pixelsHigh];
			[imageSizeLabel setStringValue:[NSString 
				stringWithFormat:@"%i x %i", x, y]];
		}
		else
		{
			// This item isn't an image. Load it's icon.
			currentImageRep = [[[fsNode iconImageOfSize:NSMakeSize(128,128)] 
				bestRepresentationForDevice:nil] retain];
			
			// Set the label to "---"
			[imageSizeLabel setStringValue:@"---"];
		}
    }
    
	[self redraw];
}

- browserDoubleClick:(id)browser {
	//	NSLog(@"Double click on %@", browser);
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
	
	if(scaleProportionally == YES)
	{
		// Set the size of the image to the size of the image scaled by our 
		// ratio and then tell the imageViewer to scale it to that size.
		displayX = imageX * scaleRatio;
		displayY = imageY * scaleRatio;
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
		}
		else
		{
			// The image needs to be scaled to fit in the box. Go through the
			// two possible ratios in terms of biggest first and check to
			// see if they work. We sort an array of the two values so we make
			// sure we aren't scaling smaller then what can be displayed on the
			// screen
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
	
	if(imageRepIsAnimated(currentImageRep))
	{
		// We know we have to resize the image representation. So let's build
		// a new one 
		NSImageRep* imageRep = [[currentImageRep copy] autorelease];
		assert(imageRepIsAnimated(imageRep));
		NSImage* image = [[[NSImage alloc] init] autorelease];
		[image addRepresentation:imageRep];
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

@end
