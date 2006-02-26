/* FileListWindowController */

#import <Cocoa/Cocoa.h>
#import "FileList.h"

@interface FileListWindowController : NSWindowController
{
    IBOutlet NSView *currentFileViewHolder;
    IBOutlet NSTextField *fileSizeLabel;
    IBOutlet NSTextField *imageSizeLabel;
	
	id<FileList> fileList;
}

-(void)setFileList:(id<FileList>)newList;
-(void)setFileSizeLabelText:(int)fileSize;
-(void)setImageSizeLabelText:(NSSize)size;

@end
