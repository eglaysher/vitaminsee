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

//////////////////////////////////////////////////////////// NSTable Datasource
- (void) tableView: (NSTableView*) tableView willDisplayCell: (id) cell 
	forTableColumn: (NSTableColumn*) tableColumn row: (int) row 
{ 
	// Manually bind each cell to it's corresponding location
    NSDictionary* filter = [[pathsController arrangedObjects] objectAtIndex:row];
    [cell bind:@"enabled" toObject:filter withKeyPath:@"Path" options:
		[NSDictionary dictionaryWithObjectsAndKeys:@"PathExistsValueTransformer", @"NSValueTransformerName", nil]
			];
} 


@end
