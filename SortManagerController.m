#import "SortManagerController.h"

#import "FileOperations.h"

@implementation SortManagerController

-(IBAction)moveButtonPushed:(id)sender
{
	int rowIndex = [sender selectedRow];
	id cellProperties = [[[NSUserDefaults standardUserDefaults] 
		objectForKey:@"SortManagerPaths"] objectAtIndex:rowIndex];
	NSString* destination = [cellProperties objectForKey:@"Path"];	
	[mainController moveThisFile:destination];
}

-(IBAction)copyButtonPushed:(id)sender
{
	int rowIndex = [sender selectedRow];
	id cellProperties = [[[NSUserDefaults standardUserDefaults] 
		objectForKey:@"SortManagerPaths"] objectAtIndex:rowIndex];
	NSString* destination = [cellProperties objectForKey:@"Path"];	
	[mainController copyThisFile:destination];
}

@end
