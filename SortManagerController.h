/* SortManagerController */

#import <Cocoa/Cocoa.h>

#import "FileManager.h"

@class PluginLayer;

@interface SortManagerController : NSWindowController <FileManagerPlugin>
{
	PluginLayer* pluginLayer;
}

// Actions from the form
-(IBAction)moveButtonPushed:(id)sender;
-(IBAction)copyButtonPushed:(id)sender;

-(void)fileSetTo:(NSString*)newPath;
@end
