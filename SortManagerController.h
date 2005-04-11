/* SortManagerController */

#import <Cocoa/Cocoa.h>

#import "CurrentFilePlugin.h"

@class PluginLayer;

@interface SortManagerController : NSWindowController <CurrentFilePlugin>
{
	PluginLayer* pluginLayer;
	IBOutlet NSArrayController* pathsController;
}

// Actions from the form
-(IBAction)moveButtonPushed:(id)sender;
-(IBAction)copyButtonPushed:(id)sender;

-(void)fileSetTo:(NSString*)newPath;
@end
