/* FileListWindowController */

#import <Cocoa/Cocoa.h>
#import "FileList.h"

@interface FileListWindowController : NSWindowController
{
    IBOutlet NSView *currentFileViewHolder;
    IBOutlet NSTextField *fileSizeLabel;
    IBOutlet NSTextField *imageSizeLabel;
	IBOutlet NSProgressIndicator* progressIndicator;
	
	id<FileList> fileList;
	
	BOOL currentlyAnimated;
}

// Methods that deal with the progress indicatator
-(void)beginCountdownToDisplayProgressIndicator;
-(void)cancelCountdown;
-(void)startProgressIndicator;
-(void)stopProgressIndicator;

-(void)setFileList:(id<FileList>)newList;
-(void)setFileSizeLabelText:(int)fileSize;
-(void)setImageSizeLabelText:(NSSize)size;

@end
