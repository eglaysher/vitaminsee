//
//  KeywordManagerPreferences.m
//  CQView
//
//  Created by Elliot on 2/27/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "KeywordManagerPreferences.h"


@implementation KeywordManagerPreferences

-(void)awakeFromNib
{
	// Unarchive the keyword data from the user defaults...
	keywordRoot = [[NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults 
		standardUserDefaults] objectForKey:@"KeywordTree"]] retain];
	[outlineView reloadData];
}

-(void)dealloc
{
	[keywordRoot release];
}

// Forum actions
-(IBAction)showHelp:(id)sender
{
	// blah
//	[[NSHelpManager sharedHelpManager] openHelpAnchor:<#(NSString *)anchor#> 
//   inBook:<#(NSString *)book#>];
}

-(IBAction)addKeyword:(id)sender
{
	NSLog(@"Sender: %@", sender);
	id currentlySelectedItem = [outlineView itemAtRow:[outlineView selectedRow]];
	NSLog(@"Currently selected item: %@", [currentlySelectedItem keyword]);
	
	[currentlySelectedItem addChild:[[[KeywordNode alloc] initWithKeyword:
		@"NEW KEYWORD"] autorelease]];
	[outlineView reloadItem:currentlySelectedItem reloadChildren:YES];
	[outlineView expandItem:currentlySelectedItem];
	// fixme: select new item.
	//	[outlineView select
}

-(IBAction)remove:(id)sender
{
	// Get the currently selected item.
//	[outlineView
}

-(void)saveKeywordsToUserDefaults
{
	NSData* emptyKeywordNode = [NSKeyedArchiver archivedDataWithRootObject:keywordRoot];
	[[NSUserDefaults standardUserDefaults] setObject:emptyKeywordNode
											  forKey:@"KeywordTree"];
}

/////////////////////////////////////////// Protocol: SS_PreferencePaneProtocol

+(NSArray*)preferencePanes
{
	return [NSArray arrayWithObjects:[[[KeywordManagerPreferences alloc]
		init] autorelease], nil];
}

- (NSView *)paneView
{
    BOOL loaded = YES;
    
    if (!prefView)
        loaded = [NSBundle loadNibNamed:@"KeywordManagerPreferences" owner:self];
    
    if (loaded)
        return prefView;
    
    return nil;
}

- (NSString *)paneName
{
    return @"Keywords";
}

- (NSImage *)paneIcon
{
	// Fix this...
    return [[[NSImage alloc] initWithContentsOfFile:
        [[NSBundle bundleForClass:[self class]] pathForImageResource:@"General_Prefs"]
        ] autorelease];
}

- (NSString *)paneToolTip
{
    return @"Keyword Preferences";
}

- (BOOL)allowsHorizontalResizing
{
    return NO;
}

- (BOOL)allowsVerticalResizing
{
    return NO;
}

///////////////////////////////////////////// NSOutlineView Data Source methods

- (int)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item {
    return (item == nil) ? 1 : [item numberOfChildren];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item {
    return (item == nil) ? YES : [item numberOfChildren];
}

- (id)outlineView:(NSOutlineView *)outlineView child:(int)index ofItem:(id)item {
	return (item == nil) ? keywordRoot :
		[[item children] objectAtIndex:index];
}

- (id)outlineView:(NSOutlineView *)outlineView 
objectValueForTableColumn:(NSTableColumn *)tableColumn 
		   byItem:(id)item {
    return (item == nil) ? 	@"Keywords" : (id)[item keyword];
}

- (void)outlineView:(NSOutlineView*)outlineView
	 setObjectValue:(id)object
	 forTableColumn:(NSTableColumn*)tableColumn
			 byItem:(id)item
{
	NSString* currentKeyword = [[item keyword] retain];
	
	NSLog(@"Changing %@ to %@", [item keyword], object);
	[item setKeyword:(NSString*)object];
	[outlineView reloadItem:item];

	if(![currentKeyword isEqual:object])
		[self saveKeywordsToUserDefaults];
	
	[currentKeyword release];
}

-(BOOL)outlineView:(NSOutlineView*)outlineView
shouldEditTableColumn:(NSTableColumn*)tableColumn
			  item:(id)item
{
	// Allow editing of any node other then the root node...
	return (item != keywordRoot);
}

@end
