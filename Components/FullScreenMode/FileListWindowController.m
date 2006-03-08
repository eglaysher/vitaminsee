#import "FileListWindowController.h"
#import "AppKitAdditions.h"

@implementation FileListWindowController

-(id)init
{	
	currentlyAnimated = NO;
	return [super initWithWindowNibName:@"FileList"];
}

/** Make the window display in the correct location.
 */
-(void)windowDidLoad
{
	[super windowDidLoad];
	[self setWindowFrameAutosaveName:@"FullScreenFileList"];
	
	// Prevent the zoom button from displaying; I am 100% sure that the user
	// does not mean to hit it, and the resulting window would be confusing.
	[[[self window] standardWindowButton:NSWindowZoomButton] setEnabled:NO];
}

//-----------------------------------------------------------------------------

-(void)beginCountdownToDisplayProgressIndicator
{
	[NSObject cancelPreviousPerformRequestsWithTarget:self
											 selector:@selector(startProgressIndicator)
											   object:nil];
	[self performSelector:@selector(startProgressIndicator)
			   withObject:nil
			   afterDelay:0.10];
}

//-----------------------------------------------------------------------------

-(void)cancelCountdown
{
	[NSObject cancelPreviousPerformRequestsWithTarget:self
											 selector:@selector(startProgressIndicator)
											   object:nil];		
}

//-----------------------------------------------------------------------------

// Progress indicator control
-(void)startProgressIndicator
{
	if(!currentlyAnimated)
	{
		[progressIndicator startAnimation:self];		
		currentlyAnimated = true;
	}
}

//-----------------------------------------------------------------------------

-(void)stopProgressIndicator
{
	[self cancelCountdown];
	
	if(currentlyAnimated) 
	{
		[progressIndicator stopAnimation:self];
		currentlyAnimated = false;
	}
}

//-----------------------------------------------------------------------------

-(void)setFileList:(id<FileList>)newList
{
	fileList = newList;
	
	id fileListView = [fileList getView];
	[currentFileViewHolder setSubview:fileListView];	
}

-(void)setFileSizeLabelText:(int)fileSize 
{
	if(fileSize == -1)
		[fileSizeLabel setObjectValue:@"---"];
	else
		[fileSizeLabel setObjectValue:[NSNumber numberWithInt:fileSize]];	
}

-(void)setImageSizeLabelText:(NSSize)size 
{
	// Truncate the size in pixels for display
	int width = size.width;
	int height = size.height;
	
	if(width == 0 && height == 0)
		[imageSizeLabel setStringValue:@"---"];
	else
		[imageSizeLabel setStringValue:[NSString stringWithFormat:@"%i x %i", 
			width, height]];	
}

@end
