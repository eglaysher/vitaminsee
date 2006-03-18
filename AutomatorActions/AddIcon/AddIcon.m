/////////////////////////////////////////////////////////////////////////
// File:          $Name$
// Module:        Add Thumbnail Icon Automator Action
// Part of:       VitaminSEE
//
// ID:            $Id: VitaminSEEController.m 123 2005-04-18 00:21:02Z elliot $
// Revision:      $Revision$
// Last edited:   $Date$
// Author:        $Author$
// Copyright:     (c) 2005 Elliot Glaysher
// Created:       6/03/05
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


#import "AddIcon.h"
#import "IconFamily.h"
#import "NSString+FileTasks.h"

@implementation AddIcon

- (id)runWithInput:(id)input fromAction:(AMAction *)anAction error:(NSDictionary **)errorInfo
{
	// Add your code here, returning the data to be passed to the next action.
	NSEnumerator* e = [input objectEnumerator];
	NSString* file;
	while(file = [e nextObject])
	{
		if([file isImage])
		{
			// This is going to take awhile; We need an autorelease pool here.
			NSAutoreleasePool* p = [[NSAutoreleasePool alloc] init];
			
			// If this file already has an icon, we need to remove it.
			if([IconFamily fileHasCustomIcon:file])
				[IconFamily removeCustomIconFromFile:file];
			
			// Build the icon
			NSImage* image = [[[NSImage alloc] initWithData:
				[NSData dataWithContentsOfFile:file]] autorelease];
			
			// Set icon
			IconFamily* iconFamily = [IconFamily iconFamilyWithThumbnailsOfImage:image];
			if(iconFamily)
				[iconFamily setAsCustomIconForFile:file];
			
			[p release];
		}
	}
	
	// Pass on the input.
	return input;
}

@end
