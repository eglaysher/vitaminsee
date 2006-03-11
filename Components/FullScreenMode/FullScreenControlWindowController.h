/* FullScreenControlWindowController */

#import <Cocoa/Cocoa.h>

@interface FullScreenControlWindowController : NSWindowController
{
    IBOutlet NSButton *leaveFullscreenButton;
    IBOutlet NSButton *nextButton;
    IBOutlet NSButton *prevButton;
}
-(void)update;
-(void)validateButton:(NSButton*)button;
@end
