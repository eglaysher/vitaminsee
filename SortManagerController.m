#import "SortManagerController.h"

#import "FileOperations.h"

@implementation SortManagerController

// I would love to destory all this code with Cocoa bindings. Regretably, it 
// seems that NSArrayController and NSActionCell don't play well together...

-(void)awakeFromNib
{
	// We want to know if there is a possible change in the list of directories
	// we show to the user...
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(userDefaultsChanged:)
												 name:NSUserDefaultsDidChangeNotification
											   object:nil];
}

-(void)userDefaultsChanged:(id)sender
{
	[tableView reloadData];
}

- (IBAction)manageButtonClicked:(id)sender
{
	// fixme: do something.
}

- (id)tableView:(NSTableView *)aTableView
   objectValueForTableColumn:(NSTableColumn *)aTableColumn
			row:(int)rowIndex
{
	NSArray* paths = [[NSUserDefaults standardUserDefaults] objectForKey:@"SortManagerPaths"];
	NSDictionary* thisPath = [paths objectAtIndex:rowIndex];

	// Set the name of the current cell...
	NSTableColumn* col = [[aTableView tableColumns] objectAtIndex:0];
	if( col )
	{
		id button = [col dataCellForRow:rowIndex];
		[button setButtonType:NSMomentaryLightButton];
		[button setBezelStyle:NSRoundedBezelStyle];
		[button setTitle:[thisPath objectForKey:@"Name"]];
		[button setRefusesFirstResponder:YES];
		[button setControlSize:NSSmallControlSize];
	}	
	
	return [thisPath objectForKey:@"Name"];
}

- (void)tableView:(NSTableView *)aTableView
   setObjectValue:anObject
   forTableColumn:(NSTableColumn *)aTableColumn
			  row:(int)rowIndex
{
	id cell = [aTableColumn dataCellForRow:rowIndex];
	NSDictionary* cellProperties = [[[NSUserDefaults standardUserDefaults] 
		objectForKey:@"SortManagerPaths"] objectAtIndex:rowIndex];
	NSString* destination = [cellProperties objectForKey:@"Path"];
	int column = [moveCopyMatrix selectedColumn];
		
	if(column == 0)
	{
//		NSLog(@"Moving current file to %@", destination);	
		[mainController moveThisFile:destination];
	}
	else
	{
//		NSLog(@"Copying current file to %@", destination);
		[mainController copyThisFile:destination];
	}
}

- (int)numberOfRowsInTableView:(NSTableView *)aTableView
{
    return [[[NSUserDefaults standardUserDefaults] objectForKey:@"SortManagerPaths"] count];
}


@end
