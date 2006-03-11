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

- (void)update
{
	[self validateButton:nextButton];
	[self validateButton:prevButton];
}

-(void)validateButton:(NSButton*)button 
{
	id validator = [NSApp targetForAction:[button action] 
									   to:[button target] 
									 from:button];

	if ((validator == nil) || ![validator respondsToSelector:[button action]]) {
		[button setEnabled:NO];
	} else if ([validator respondsToSelector:@selector(validateAction:)]) {
		[button setEnabled:[validator validateAction:[button action]]];
	} else {
		[button setEnabled:YES];
	}	
}

@end
