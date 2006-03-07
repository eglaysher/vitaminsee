#import "FullScreenControlWindowController.h"

@implementation FullScreenControlWindowController

-(id)init
{
	return [super initWithWindowNibName:@"Controls"];
}

/** Make the window display in the correct location.
*/
-(void)windowDidLoad
{
	[super windowDidLoad];
	[self setWindowFrameAutosaveName:@"FullScreenControlls"];
}

@end
