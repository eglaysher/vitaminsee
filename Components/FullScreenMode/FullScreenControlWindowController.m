#import "FullScreenControlWindowController.h"

@implementation FullScreenControlWindowController

-(id)init
{
	return [super initWithWindowNibName:@"Controls"];
}

-(void)awakeFromNib
{
	// Don't cascade windows so that autosave positioning works correctly.
	[self setShouldCascadeWindows:NO];
}

/** Make the window display in the correct location.
 */
-(void)windowDidLoad
{
	[super windowDidLoad];
	[self setWindowFrameAutosaveName:@"FullScreenControlls"];
}

@end
