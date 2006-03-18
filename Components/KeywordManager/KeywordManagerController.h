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

#import <Cocoa/Cocoa.h>

#import "CurrentFilePlugin.h"

@class KeywordNode;

@interface KeywordManagerController : NSWindowController <CurrentFilePlugin>
{
	IBOutlet NSTextField* fileNameTextFieldLabel;
	IBOutlet NSTextField* fileNameTextField;
	IBOutlet NSTextField* currentKeywordsTextViewLabel;
	IBOutlet NSTextView* currentKeywordsTextView;
	IBOutlet NSTextField* outlineViewLabel;
	IBOutlet NSOutlineView* outlineView;

	KeywordNode* keywordRoot;
	
	BOOL keywordsDirty;
	NSString* currentPath;
	NSMutableArray* keywords;
}

-(IBAction)cellClicked:(id)sender;
-(IBAction)keywordTextViewChanged:(id)sender;
//-(IBAction)fileChanged:(id)sender;

-(void)saveKeywords;
-(void)loadKeywords;

-(void)enableAllCells;
-(void)disableAllCells;

-(void)loadKeywordTree;
-(void)loadKeywordsIntoTextViewFromList;
-(void)loadKeywordsIntoListFromTextView;

-(BOOL)supportsKeywords:(NSString*)file;
//-(void)fileSetTo:(NSString*)newPath;

@end
