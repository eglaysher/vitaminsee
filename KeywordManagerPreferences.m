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

-(IBAction)addCategory:(id)sender
{
	// Add a category
}

-(IBAction)addKeyword:(id)sender
{
	
}

-(IBAction)remove:(id)sender
{
	
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
	if(item == nil)
	{
		NSLog(@"KR: %@", keywordRoot);
		NSLog(@"The number Of children of <nil> is %d", [keywordRoot numberOfChildren]);
		return [keywordRoot numberOfChildren];
	}
	else
	{
		NSLog(@"The number of children of %@ is %d", item, [item numberOfChildren]);
		return [item numberOfChildren];
	}
//    return (item == nil) ? [keywordRoot numberOfChildren] : [item numberOfChildren];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item {
    return (item == nil) ? [keywordRoot numberOfChildren] : [item numberOfChildren];
}

- (id)outlineView:(NSOutlineView *)outlineView child:(int)index ofItem:(id)item {
	NSLog(@"KR: %@", keywordRoot);
	id retVal = (item == nil) ? [[keywordRoot children] objectAtIndex:index] :
		[[item children] objectAtIndex:index];
	NSLog(@"Item: %@", retVal);
	return retVal;
}

- (id)outlineView:(NSOutlineView *)outlineView 
objectValueForTableColumn:(NSTableColumn *)tableColumn 
		   byItem:(id)item {
    return (item == nil) ? 	@"/" : (id)[item keyword];
}

// NSOutlinveView Delegate methods

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldEditTableColumn:(NSTableColumn *)tableColumn item:(id)item {
    return NO;
}


@end
