/////////////////////////////////////////////////////////////////////////
// File:          $Name$
// Module:        Implements the drop down sheet asking for a folder name that's
//                accessable from Go > Goto Folder...
// Part of:       VitaminSEE
//
// Revision:      $Revision$
// Last edited:   $Date$
// Author:        $Author$
// Copyright:     (c) 2005 Elliot Glaysher
// Created:       3/10/05
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
#import "PluginBase.h"

@interface GotoFolderSheetController : NSWindowController <PluginBase> {
	IBOutlet NSTextField* folderName;
	NSTimer* timer;
	
	bool cancel;
	id target;
	SEL returnSelector;
}

-(void)showSheet:(NSWindow*)window 
	initialValue:(NSString*)initialValue
		  target:(id)inTarget 
		selector:(SEL)selector;

-(IBAction)type:(id)sender;
-(IBAction)clickOK:(id)sender;
-(IBAction)clickCancel:(id)sender;

-(void)completeText:(id)sender;

@end
