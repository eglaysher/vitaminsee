//
//  KeywordManager.m
//  CQView
//
//  Created by Elliot on 3/3/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "KeywordManagerController.h"

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
		NSLog(@"TextView; %@", [currentKeywordsTextView string]);
	}
	
	NSLog(@"Hi my name is %@", self);
	
	return self;
}

-(void)dealloc
{
	[keywords release];
}

////////////////////////////////////////////////// Actions from the form
-(IBAction)cellClicked:(id)sender
{
	NSString* keyword = [[sender selectedCell] title];
	if([keywords containsObject:keyword])
	{
		NSLog(@"Removing keyword %@", keyword);
		[keywords removeObject:keyword];
	}
	else
	{
		NSLog(@"Adding keyword %@", keyword);
		[keywords addObject:keyword];
	}

	[self loadKeywordsIntoTextViewFromList];
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
	NSLog(@"New value is %@", [sender stringValue]);
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

//////////////////////////////////////////////// Protocol: FileManagerPlugin

-(void)setPluginLayer:(CQViewController*)layer
{
	pluginLayer = layer;
}

-(void)fileSetTo:(NSString*)newPath
{
	// Need to keep track of the current image.
	[currentPath release];
	currentPath = newPath;
	[currentPath retain];
	
	NSLog(@"Setting Keyword path to %@ in %@", [currentPath lastPathComponent],
		  fileNameTextField);
	[fileNameTextField setStringValue:[currentPath lastPathComponent]];
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
