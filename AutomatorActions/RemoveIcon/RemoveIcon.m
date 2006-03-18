/////////////////////////////////////////////////////////////////////////
// File:          $Name$
// Module:        Remove Thumbnail Icon Automator Action
// Part of:       VitaminSEE
//
// ID:            $Id: VitaminSEEController.m 123 2005-04-18 00:21:02Z elliot $
// Revision:      $Revision$
// Last edited:   $Date$
// Author:        $Author$
// Copyright:     (c) 2005 Elliot Glaysher
// Created:       6/04/05
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


#import "RemoveIcon.h"
#import "IconFamily.h"

@implementation RemoveIcon

- (id)runWithInput:(id)input fromAction:(AMAction *)anAction error:(NSDictionary **)errorInfo
{
	// For each file that has a custom icon, remove it.
	NSEnumerator* e = [input objectEnumerator];
	NSString* filePath;
	while(filePath = [e nextObject])
		if([IconFamily fileHasCustomIcon:filePath]) {
			NSAutoreleasePool* p = [[NSAutoreleasePool alloc] init];
			
			[IconFamily removeCustomIconFromFile:filePath];
			
			[p release];
		}

	// Pass on the list of files
	return input;
}

@end
