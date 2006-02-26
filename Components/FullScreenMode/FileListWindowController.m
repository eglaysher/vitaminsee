#import "FileListWindowController.h"
#import "AppKitAdditions.h"

@implementation FileListWindowController

-(id)init
{	
	return [super initWithWindowNibName:@"FileList"];
}

/** Make the window display in the correct location.
 */
-(void)windowDidLoad
{
	[super windowDidLoad];
	[self setWindowFrameAutosaveName:@"FullScreenFileList"];
}

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
