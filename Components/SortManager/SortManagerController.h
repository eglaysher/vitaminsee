/////////////////////////////////////////////////////////////////////////
// File:          $URL$
// Module:        Implements the Sort Manager panel
// Part of:       VitaminSEE
//
// Revision:      $Revision$
// Last edited:   $Date$
// Author:        $Author$
// Copyright:     (c) 2005 Elliot Glaysher
// Created:       2/13/05
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

@class EGPath;

@interface SortManagerController : NSWindowController <CurrentFilePlugin>
{
	IBOutlet NSArrayController* pathsController;
	IBOutlet NSTableView* tableView;
	NSMutableDictionary* keyValues;
	EGPath* currentFile;
}

// Actions from the form
-(IBAction)moveButtonPushed:(id)sender;
-(IBAction)copyButtonPushed:(id)sender;

-(void)fileSetTo:(EGPath*)newPath;
@end
