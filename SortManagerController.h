/* SortManagerController */

#import <Cocoa/Cocoa.h>

@class CQViewController;

@interface SortManagerController : NSWindowController
{
    IBOutlet CQViewController *mainController;
}

-(IBAction)moveButtonPushed:(id)sender;
-(IBAction)copyButtonPushed:(id)sender;

@end
