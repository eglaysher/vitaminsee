/////////////////////////////////////////////////////////////////////////
// File:          $Name$
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
// This library is free software; you can redistribute it and/or
// modify it under the terms of the GNU Lesser General Public
// License as published by the Free Software Foundation; either
// version 2.1 of the License, or (at your option) any later version.
//  
// This library is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
// Lesser General Public License for more details.
//  
// You should have received a copy of the GNU Lesser General Public
// License along with this library; if not, write to the Free Software
// Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  
// USA
//
/////////////////////////////////////////////////////////////////////////

#import <Cocoa/Cocoa.h>

#import "CurrentFilePlugin.h"

@class KeywordNode;

@interface KeywordManagerController : NSWindowController <CurrentFilePlugin>
{
	IBOutlet NSTextField* fileNameTextField;
	IBOutlet NSTextView* currentKeywordsTextView;
	IBOutlet NSOutlineView* outlineView;

	PluginLayer* pluginLayer;
//	VitaminSEEController* pluginLayer;	
	KeywordNode* keywordRoot;
	
	BOOL keywordsDirty;
	NSString* currentPath;
	NSMutableArray* keywords;
}

-(IBAction)cellClicked:(id)sender;
-(IBAction)keywordTextViewChanged:(id)sender;
-(IBAction)fileChanged:(id)sender;

-(void)saveKeywords;
-(void)loadKeywords;

-(void)enableAllCells;
-(void)disableAllCells;

-(void)loadKeywordTree;
-(void)loadKeywordsIntoTextViewFromList;
-(void)loadKeywordsIntoListFromTextView;

-(void)fileSetTo:(NSString*)newPath;

// Get the plugin name
-(NSString*)name;

// Most plugins will have a show window
-(void)activate;

// Context menu items for this plugin.
-(NSArray*)contextMenuItems;

@end
