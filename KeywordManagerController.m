//
//  KeywordManager.m
//  CQView
//
//  Created by Elliot on 3/3/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "KeywordManagerController.h"
#import "PluginLayer.h"
#import "KeywordNode.h"

@implementation KeywordManagerController

-(id)init
{
	// Load the nib file
	if(self = [super initWithWindowNibName:@"KeywordManager"])
	{
		keywords = [[NSMutableArray alloc] init];
		
		// Before we thaw the window, we need to have a valid KeywordNode tree,
		// so load them from the user defaults.
		[self loadKeywordTree];
		
		// We need to be alerted when the keyword root has changed. Bindings would
		// take care of this for us, but NSOutlineView has no #@$%!& bindings.
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(loadKeywordTree)
													 name:NSUserDefaultsDidChangeNotification
												   object:nil];	

		// Ignore return value; we just want the window loaded and the docs say
		// we shouldn't call loadWindow. We need this since fileSetTo: will be
		// called before the window would otherwise be initialized.
		[self window];

		[self loadKeywordsIntoTextViewFromList];
//		[currentKeywordsTextView insertText:@"One\nTwo\nThree\n"];
//		NSLog(@"TextView; %@", [currentKeywordsTextView string]);
	}
	
//	NSLog(@"Hi my name is %@", self);
	
	return self;
}

-(void)dealloc
{
	if(keywordsDirty)
		[self saveKeywords];
	
	[keywords release];
}

////////////////////////////////////////////////// Actions from the form
-(IBAction)cellClicked:(id)sender
{
	NSString* keyword = [[sender selectedCell] title];
	if([keywords containsObject:keyword])
	{
//		NSLog(@"Removing keyword %@", keyword);
		[keywords removeObject:keyword];
	}
	else
	{
//		NSLog(@"Adding keyword %@", keyword);
		[keywords addObject:keyword];
	}

	[self loadKeywordsIntoTextViewFromList];
	keywordsDirty = YES;
}

-(IBAction)keywordTextViewChanged:(id)sender
{
	[self loadKeywordsIntoListFromTextView]; 
}

-(IBAction)fileChanged:(id)sender
{
	NSString* path = [currentPath stringByDeletingLastPathComponent];
//	NSString* current

	// fixme: Get renaming working.
//	NSLog(@"New value is %@", [sender stringValue]);
	
	[pluginLayer renameThisFileTo:[sender stringValue]];
}


-(void)loadKeywordsIntoTextViewFromList
{
	[currentKeywordsTextView setString:[keywords componentsJoinedByString:@"\n"]];
}

-(void)loadKeywordsIntoListFromTextView
{
	[keywords removeAllObjects];
	
	// Get the string in the text view.
	NSArray* newKeywords = [[currentKeywordsTextView string] componentsSeparatedByString:@"\n"];

	NSEnumerator* e = [newKeywords objectEnumerator];
	NSString* k;
	while(k = [e nextObject])
	{
		NSString* trimmed = [k stringByTrimmingCharactersInSet:[NSCharacterSet 
			whitespaceAndNewlineCharacterSet]];
		if(![trimmed isEqualTo:@""])
			[keywords addObject:trimmed];
	}
	
	keywordsDirty = YES;
	[outlineView reloadItem:keywordRoot reloadChildren:YES];
	[outlineView setNeedsDisplay:YES];
}

-(void)loadKeywordTree
{
	[keywordRoot release];
	keywordRoot = [[NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults 
		standardUserDefaults] objectForKey:@"KeywordTree"]] retain];	
	
	// Inform the outlineView that it has to do a total redisplay.
	[outlineView reloadData];
}

-(void)saveKeywords
{
	// Save the keywords to disk
	[pluginLayer setKeywords:keywords forFile:currentPath];	
	keywordsDirty = NO;
}

-(void)loadKeywords
{
	// Print out the key
	keywordsDirty = NO;
	id newkeywords = [pluginLayer getKeywordsFromFile:currentPath];
	if(newkeywords)
	{
		// This file already has keywords. Use them.
		[keywords release];
		keywords = newkeywords;
		[keywords retain];
	}
	else
	{
		// Allocate a new array since we don't have one
		[keywords release];
		keywords = [[NSMutableArray alloc] init];
	}
	
	[outlineView reloadItem:keywordRoot reloadChildren:YES];
	[outlineView setNeedsDisplay:YES];
	
	[self loadKeywordsIntoTextViewFromList];
	
//	NSLog(@"New keywords: %@", newkeywords);	
}

/////////////////////////////////////////////////// NSTextView notification
-(void)textDidChange:(NSNotification*)aNotification
{
	[self loadKeywordsIntoListFromTextView];
}

////////////////////////////////////////////////// NSOutlineView datasource & delegate
- (int)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item {
    return (item == nil) ? [keywordRoot numberOfChildren] : [item numberOfChildren];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item {
    return (item == nil) ? [keywordRoot numberOfChildren] : [item numberOfChildren];
}

- (id)outlineView:(NSOutlineView *)outlineView child:(int)index ofItem:(id)item {
    return (item == nil) ? [[keywordRoot children] objectAtIndex:index] :
	[[item children] objectAtIndex:index];
}

- (id)outlineView:(NSOutlineView *)outlineView 
objectValueForTableColumn:(NSTableColumn *)tableColumn 
		   byItem:(id)item {
    return (item == nil) ? 	@"/" : (id)[item keyword];
}

// Delegate methods

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldEditTableColumn:(NSTableColumn *)tableColumn item:(id)item {
    return NO;
}

- (void)outlineView:(NSOutlineView *)outlineView willDisplayCell:(id)cell 
	 forTableColumn:(NSTableColumn *)tableColumn item:(id)item
{
	[cell setTitle:[item keyword]];
	
	// If the keyword exists in the list of keywords, then set to the on state.
	if([keywords containsObject:[item keyword]])
		[cell setState:NSOnState];
	else
		[cell setState:NSOffState];
}

-(void)enableAllCells
{
	// Get all the cells 
	int numberOfCells = [outlineView numberOfRows];
	id tableColumn = [[outlineView tableColumns] objectAtIndex:0];
	int i = 0;
	for(i = 0; i < numberOfCells; ++i)
	{
		[[tableColumn dataCellForRow:i] setEnabled:YES];
	}
	
	[outlineView setNeedsDisplay];
}

-(void)disableAllCells
{
	int numberOfCells = [outlineView numberOfRows];
	id tableColumn = [[outlineView tableColumns] objectAtIndex:0];
	int i = 0;
	for(i = 0; i < numberOfCells; ++i)
	{
		[[tableColumn dataCellForRow:i] setEnabled:NO];
	}
	
	[outlineView setNeedsDisplay];	
}

//////////////////////////////////////////////// Protocol: FileManagerPlugin

-(void)setPluginLayer:(VitaminSEEController*)layer
{
	pluginLayer = layer;
}

-(void)fileSetTo:(NSString*)newPath
{
	// save the old data if needed
	if(keywordsDirty)
		[self saveKeywords];
	
	// Need to keep track of the current image.
	[currentPath release];
	currentPath = newPath;
	[currentPath retain];
	
	[fileNameTextField setStringValue:[currentPath lastPathComponent]];

	// Let's check if we can set keywords
	if([pluginLayer supportsKeywords:newPath])
	{
		// First, make sure the relevant sections are enabled:
		[outlineView setEnabled:YES];
		[self enableAllCells];
		[outlineView setNeedsDisplay:YES];
		[currentKeywordsTextView setEditable:YES];
		[self loadKeywords];			
	}
	else
	{
		// We can't deal with keywords so don't allow entry there
		[outlineView setEnabled:NO];
		[self disableAllCells];
		[outlineView setNeedsDisplay:YES];
		[currentKeywordsTextView setEditable:NO];
	}
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
