#import "SortManagerController.h"

@implementation SortManagerController

- (IBAction)addButtonClicked:(id)sender
{
}

- (IBAction)copyMoveSelectionChanged:(id)sender
{
}

- (IBAction)removeButtonClicked:(id)sender
{
	
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

	NSLog(@"Moving current file to %@", destination);
	
	[mainController moveThisFile:destination];
//	[mainController moveCurrentFileToPath:destination];
}

- (int)numberOfRowsInTableView:(NSTableView *)aTableView
{
    return [[[NSUserDefaults standardUserDefaults] objectForKey:@"SortManagerPaths"] count];
}

@end
