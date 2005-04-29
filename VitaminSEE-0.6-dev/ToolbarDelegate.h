/////////////////////////////////////////////////////////////////////////
// File:          $Name$
// Module:        Category responsible for managing the toolbar
// Part of:       VitaminSEE
//
// Revision:      $Revision$
// Last edited:   $Date$
// Author:        $Author$
// Copyright:     (c) 2005 Elliot Glaysher
// Created:       1/30/05
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


#import "VitaminSEEController.h"

@interface VitaminSEEController (ToolbarDelegate)

-(void)setupToolbar;

- (NSToolbarItem *) toolbar: (NSToolbar *)toolbar
	  itemForItemIdentifier: (NSString *) itemIdent 
  willBeInsertedIntoToolbar:(BOOL) willBeInserted;

- (NSArray *) toolbarDefaultItemIdentifiers: (NSToolbar *) toolbar;
- (NSArray *) toolbarAllowedItemIdentifiers: (NSToolbar *) toolbar;
@end
