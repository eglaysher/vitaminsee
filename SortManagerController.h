/* SortManagerController */

#import <Cocoa/Cocoa.h>

@class CQViewController;

@interface SortManagerController : NSWindowController
{
    IBOutlet CQViewController *mainController;
	IBOutlet NSMatrix* moveCopyMatrix;
}
- (IBAction)manageButtonClicked:(id)sender;

@end
