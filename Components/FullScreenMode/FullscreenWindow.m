#import "FullscreenWindow.h"



@implementation FullscreenWindow

-(id)initWithContentRect:(NSRect)contentRect
			   styleMask:(unsigned int)aStyle
				 backing:(NSBackingStoreType)bufferingType
				   defer:(BOOL)flag
{
	self = [super initWithContentRect:contentRect 
							styleMask:NSBorderlessWindowMask 
							  backing:NSBackingStoreBuffered 
								defer:YES];	
	return self;
}

-(BOOL)canBecomeKeyWindow
{
	return YES;
}

-(BOOL)canBecomeMainWindow
{
	return YES;
}

@end
