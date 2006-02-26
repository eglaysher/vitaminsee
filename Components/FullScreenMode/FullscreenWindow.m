#import "FullscreenWindow.h"

@implementation FullscreenWindow

- (id)initWithContentRect:(NSRect)contentRect styleMask:(unsigned int)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag
{
	NSLog(@"Custom super build!");
	self = [super initWithContentRect:contentRect 
							styleMask:NSBorderlessWindowMask 
							  backing:NSBackingStoreBuffered 
								defer:YES];
//	[self setMovableByWindowBackground:YES];
	
	return self;
}

- (BOOL) canBecomeKeyWindow
{
	return YES;
}

@end
