/* SortManagerController */

#import <Cocoa/Cocoa.h>

#import "FileManager.h"

@interface SortManagerController : NSWindowController <FileManagerPlugin>
{
	CQViewController* pluginLayer;
}

// Actions from the form
-(IBAction)moveButtonPushed:(id)sender;
-(IBAction)copyButtonPushed:(id)sender;

-(void)fileSetTo:(NSString*)newPath;

// Get the plugin name
-(NSString*)name;

// Most plugins will have a show window
-(void)activate;

// Context menu items for this plugin.
-(NSArray*)contextMenuItems;

@end
