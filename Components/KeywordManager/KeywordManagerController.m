/////////////////////////////////////////////////////////////////////////
// File:          $URL$
// Module:        Implements the Keyword editing panel
// Part of:       VitaminSEE
//
// Revision:      $Revision$
// Last edited:   $Date$
// Author:        $Author$
// Copyright:     (c) 2005 Elliot Glaysher
// Created:       3/3/05
//
/////////////////////////////////////////////////////////////////////////
//
// This program is free software; you can redistribute it and/or
// modify it under the terms of the GNU General Public License
// as published by the Free Software Foundation; either version 2
// of the License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program; if not, write to the Free Software
// Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
//
////////////////////////////////////////////////////////////////////////

#import "KeywordManagerController.h"
#import "KeywordNode.h"
#import "ComponentManager.h"
#import "EGPath.h"
#import "ImageMetadata.h"

@implementation KeywordManagerController

+(void)initialize
{
	// Set up this application's default preferences	
    NSMutableDictionary *defaultPrefs = [NSMutableDictionary dictionary];
	
	// Keyword preferences
	KeywordNode* node = [[[KeywordNode alloc] initWithParent:nil keyword:@"Keywords"] autorelease];
	NSData* emptyKeywordNode = [NSKeyedArchiver archivedDataWithRootObject:node];
	[defaultPrefs setObject:emptyKeywordNode forKey:@"KeywordTree"];
	
	[[NSUserDefaults standardUserDefaults] registerDefaults: defaultPrefs];
}

// ---------------------------------------------------------------------------

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
		// take care of this for us, but NSOutlineView has no #@$%!& bindings in
		// Panther and we want to stay compatible for a bit longer.
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(loadKeywordTree)
													 name:NSUserDefaultsDidChangeNotification
												   object:nil];	

		// Ignore return value; we just want the window loaded and the docs say
		// we shouldn't call loadWindow. We need this since fileSetTo: will be
		// called before the window would otherwise be initialized.
		[self window];

		[self loadKeywordsIntoTextViewFromList];
	}
	
	return self;
}

// ---------------------------------------------------------------------------

-(void)dealloc
{
	if(keywordsDirty)
		[self saveKeywords];
	
	[keywords release];
	[super dealloc];
}

// ---------------------------------------------------------------------------

-(void)windowDidLoad
{
	[super windowDidLoad];
	
	[self setShouldCascadeWindows:NO];
	[self setWindowFrameAutosaveName:@"keywordManagerWindowPosition"];
}

////////////////////////////////////////////////// Actions from the form
-(IBAction)cellClicked:(id)sender
{
	NSString* keyword = [[sender selectedCell] title];
	if([keywords containsObject:keyword])
	{
		[keywords removeObject:keyword];
	}
	else
	{
		[keywords addObject:keyword];
	}

	[self loadKeywordsIntoTextViewFromList];
	keywordsDirty = YES;
}

// ---------------------------------------------------------------------------

-(IBAction)keywordTextViewChanged:(id)sender
{
	[self loadKeywordsIntoListFromTextView]; 
}

// ---------------------------------------------------------------------------

-(void)loadKeywordsIntoTextViewFromList
{
	[currentKeywordsTextView setString:[keywords componentsJoinedByString:@"\n"]];
}

// ---------------------------------------------------------------------------

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

// ---------------------------------------------------------------------------

-(void)loadKeywordTree
{
	[keywordRoot release];
	keywordRoot = [[NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults 
		standardUserDefaults] objectForKey:@"KeywordTree"]] retain];	
	
	// Inform the outlineView that it has to do a total redisplay.
	[outlineView reloadData];
}

// ---------------------------------------------------------------------------

-(void)saveKeywords
{
	// Save the keywords to disk
	[[ComponentManager getInteranlComponentNamed:@"ImageMetadata"]
		setKeywords:keywords forJPEGFile:currentPath];	
	keywordsDirty = NO;
}

// ---------------------------------------------------------------------------

-(void)loadKeywords
{
	// Print out the key
	keywordsDirty = NO;
	id newkeywords = [[ComponentManager getInteranlComponentNamed:@"ImageMetadata"] 
		getKeywordsFromJPEGFile:currentPath];
	
	if(newkeywords)
	{
		// This file already has keywords. Use them.
		[newkeywords retain];
		[keywords release];
		keywords = newkeywords;
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

// ---------------------------------------------------------------------------

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item {
    return (item == nil) ? [keywordRoot numberOfChildren] : [item numberOfChildren];
}

// ---------------------------------------------------------------------------

- (id)outlineView:(NSOutlineView *)outlineView child:(int)index ofItem:(id)item {
    return (item == nil) ? [[keywordRoot children] objectAtIndex:index] :
	[[item children] objectAtIndex:index];
}

// ---------------------------------------------------------------------------

- (id)outlineView:(NSOutlineView *)outlineView 
objectValueForTableColumn:(NSTableColumn *)tableColumn 
		   byItem:(id)item {
    return (item == nil) ? 	@"/" : (id)[item keyword];
}

// Delegate methods

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldEditTableColumn:(NSTableColumn *)tableColumn item:(id)item {
    return NO;
}

// ---------------------------------------------------------------------------

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

// ---------------------------------------------------------------------------

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

// ---------------------------------------------------------------------------

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

/////////////////////////////////////////////////// Protocol: CurrentFilePlugin

-(void)activatePluginWithFile:(EGPath*)path inWindow:(NSWindow*)window
					  context:(NSDictionary*)context
{
	[self showWindow:self];
	[self currentImageSetTo:path];
}

// ---------------------------------------------------------------------------

-(void)currentImageSetTo:(EGPath*)path;
{
	NSString* newPath;
	if([path isNaturalFile]) 
		newPath = [path fileSystemPath];
	else
		newPath = nil;
	
	// save the old data if needed
	if(keywordsDirty)
		[self saveKeywords];
	
	if(newPath)
	{
		// Need to keep track of the current image.
		[newPath retain];
		[currentPath release];
		currentPath = newPath;

		// Let's check if we can set keywords
		if([self supportsKeywords:newPath])
		{
			// First, make sure the relevant sections are enabled:
			[outlineViewLabel setEnabled:YES];
			[outlineView setEnabled:YES];
			[self enableAllCells];
			[outlineView setNeedsDisplay:YES];
			
			[currentKeywordsTextViewLabel setEnabled:YES];
			[currentKeywordsTextView setEditable:YES];
			[self loadKeywords];			
		}
		else
		{
			// We can't deal with keywords so don't allow entry there
			[outlineView setEnabled:NO];
			[self disableAllCells];
			[outlineView setNeedsDisplay:YES];
			[currentKeywordsTextViewLabel setEnabled:NO];
			[currentKeywordsTextView setString:@""];
			[currentKeywordsTextView setEditable:NO];
		}
	}
	else
	{
		[currentPath release];
		currentPath = 0;
		
		// Disable everything
		[fileNameTextFieldLabel setEnabled:NO];
		[fileNameTextField setStringValue:@""];
		[fileNameTextField setEnabled:NO];
		
		[outlineViewLabel setEnabled:NO];
		[outlineView setEnabled:NO];
		
		[self disableAllCells];
		
		[outlineView setNeedsDisplay:YES];
	
		[currentKeywordsTextViewLabel setEnabled:NO];
		[currentKeywordsTextView setEditable:NO];		
	}
}

// ---------------------------------------------------------------------------

-(BOOL)supportsKeywords:(NSString*)file
{
	NSString* type = [[file pathExtension] uppercaseString];
	BOOL canKeyword = NO;
	if([type isEqualTo:@"JPG"] || [type isEqualTo:@"JPEG"])
		canKeyword = YES;
	
	return canKeyword;
}

// ---------------------------------------------------------------------------

-(NSUndoManager*)undoManager
{
	return [[[[NSApp mainWindow] windowController] document] undoManager];
}

@end
