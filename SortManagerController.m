#import "SortManagerController.h"
#import "PluginLayer.h"

@implementation SortManagerController

-(id)init
{
	// Load the nib file
	if(self = [super initWithWindowNibName:@"SortManager"])
	{
		// stuff could go here.
	}
	
	return self;
}

-(IBAction)moveButtonPushed:(id)sender
{
	int rowIndex = [sender selectedRow];
	id cellProperties = [[[NSUserDefaults standardUserDefaults] 
		objectForKey:@"SortManagerPaths"] objectAtIndex:rowIndex];
	NSString* destination = [cellProperties objectForKey:@"Path"];	

//	NSLog(@"Moving row %d, '%@'", rowIndex, destination);
	[pluginLayer moveThisFile:destination];
}

-(IBAction)copyButtonPushed:(id)sender
{
	int rowIndex = [sender selectedRow];
	id cellProperties = [[[NSUserDefaults standardUserDefaults] 
		objectForKey:@"SortManagerPaths"] objectAtIndex:rowIndex];
	NSString* destination = [cellProperties objectForKey:@"Path"];

//	NSLog(@"Copying row %d, '%@'", rowIndex, destination);
	[pluginLayer copyThisFile:destination];
}

-(void)setPluginLayer:(VitaminSEEController*)layer
{
	pluginLayer = layer;
}

-(void)fileSetTo:(NSString*)newPath
{
	// Ignore. We just use the "this file" commands in 
}

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
