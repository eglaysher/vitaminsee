#import "SortManagerController.h"
#import "PluginLayer.h"

@implementation SortManagerController

////////////////////////////////////////////////////////// PROTOCOL: PluginBase
-(id)initWithPluginLayer:(PluginLayer*)inPluginLayer;
{
	// Load the nib file
	if(self = [super initWithWindowNibName:@"SortManager"])
	{
		// stuff could go here.
		pluginLayer = inPluginLayer;
		[pluginLayer retain];
	}
	
	return self;
}

-(void)dealloc
{
	[pluginLayer release];
}

-(void)windowDidLoad
{
	[super windowDidLoad];
	
	[self setShouldCascadeWindows:NO];
	[self setWindowFrameAutosaveName:@"sortManagerWindowPosition"];
}

-(IBAction)moveButtonPushed:(id)sender
{
	int rowIndex = [sender selectedRow];
	id cellProperties = [[[NSUserDefaults standardUserDefaults] 
		objectForKey:@"SortManagerPaths"] objectAtIndex:rowIndex];
	NSString* destination = [cellProperties objectForKey:@"Path"];	

//	NSLog(@"Moving row %d, '%@'", rowIndex, destination);
	[pluginLayer moveFile:[pluginLayer currentFile]
					   to:destination];
}

-(IBAction)copyButtonPushed:(id)sender
{
	int rowIndex = [sender selectedRow];
	id cellProperties = [[[NSUserDefaults standardUserDefaults] 
		objectForKey:@"SortManagerPaths"] objectAtIndex:rowIndex];
	NSString* destination = [cellProperties objectForKey:@"Path"];

	[pluginLayer copyFile:[pluginLayer currentFile]
					   to:destination];
}

-(void)fileSetTo:(NSString*)newPath
{
	// Ignore. We just use the "this file" commands in 
}

/////////////////////////////////////////////////// PROTOCOL: CurrentFilePlugin
-(NSString*)name
{
	return @"Sort Manager";
}

-(void)activate
{
	[self showWindow:self];
}

-(NSArray*)contextMenuItems
{
	return nil;
}

@end
