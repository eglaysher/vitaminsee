/////////////////////////////////////////////////////////////////////////
// File:          $Name$
// Module:        Implements the Favorites preference panel
// Part of:       VitaminSEE
//
// Revision:      $Revision: 149 $
// Last edited:   $Date: 2005-04-29 14:32:49 -0400 (Fri, 29 Apr 2005) $
// Author:        $Author: elliot $
// Copyright:     (c) 2005 Elliot Glaysher
// Created:       2/22/05
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
/////////////////////////////////////////////////////////////////////////

#import <Cocoa/Cocoa.h>

#import "SS_PreferencePaneProtocol.h"

@interface AdvancedPreferencesController : NSObject <SS_PreferencePaneProtocol> 
{
	IBOutlet NSView* prefView;
}

-(IBAction)showHelp:(id)sender;

@end
