//
//  KeywordManagerPreferences.m
//  CQView
//
//  Created by Elliot on 2/27/05.
//  Copyright 2005 Elliot Glaysher. All rights reserved.
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
	[[NSHelpManager sharedHelpManager] openHelpAnchor:@"KEYWORD_MANAGER_PREFERENCES_ANCHOR"
											   inBook:@"VitaminSEE Help"];
}

-(IBAction)addKeyword:(id)sender
{
	id currentlySelectedItem = [outlineView itemAtRow:[outlineView selectedRow]];

	// Add a new keyword with the currently selected node as the parent.
	[currentlySelectedItem addChild:[[[KeywordNode alloc] initWithParent:currentlySelectedItem
																 keyword:@"NEW KEYWORD"] autorelease]];
	[self saveKeywordsToUserDefaults];
	
	[outlineView reloadItem:currentlySelectedItem reloadChildren:YES];
	[outlineView expandItem:currentlySelectedItem];
	// fixme: select new item.
	//	[outlineView select
}

-(IBAction)remove:(id)sender
{
	// Get the currently selected item.
	id selectedItem = [outlineView itemAtRow:[outlineView selectedRow]];
	id parent = [selectedItem parent];
	[parent removeChild:selectedItem];
	[self saveKeywordsToUserDefaults];
	
	// It's stupid, but we have to reload the whole tree. Reloading from the 
	// parent node results in ghost items
	[outlineView reloadItem:keywordRoot reloadChildren:YES];
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
        [[NSBundle bundleForClass:[self class]] pathForImageResource:@"KeywordManager"]
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

- (void)outlineView:(NSOutlineView*)thisOutlineView
	 setObjectValue:(id)object
	 forTableColumn:(NSTableColumn*)tableColumn
			 byItem:(id)item
{
	NSString* currentKeyword = [[item keyword] retain];
	
//	NSLog(@"Changing %@ to %@", [item keyword], object);
	[item setKeyword:(NSString*)object];
	[thisOutlineView reloadItem:item];

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
