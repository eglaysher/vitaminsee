/////////////////////////////////////////////////////////////////////////
// File:          $Name$
// Module:        ValueTransformer that turns a UNIX path to a full mac path
// Part of:       VitaminSEE
//
// Revision:      $Revision: 155 $
// Last edited:   $Date: 2005-05-04 11:37:41 -0400 (Wed, 04 May 2005) $
// Author:        $Author: glaysher $
// Copyright:     (c) 2005 Elliot Glaysher
// Created:       5/2/05
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

#import "FullDisplayNameValueTransformer.h"


@implementation FullDisplayNameValueTransformer
+(Class)transformedValueClass
{
	return [NSString class];
}

+(BOOL)allowsReverseTransformation
{
	return NO;
}

// value input is of type "/Useres/elliot/..."
// output is of type "Macintosh HD:Users:elliot:..."
-(id)transformedValue:(id)value
{
	NSEnumerator* e = [[[NSFileManager defaultManager] 
		componentsToDisplayForPath:value] objectEnumerator];
	NSString* next = [e nextObject];
	NSMutableString* displayPath;
	
	if(next)
	{
		displayPath = [[next mutableCopy] autorelease];
		NSString* current;
	
		// For each additional component after the first, 
		while(current = [e nextObject])
		{
			[displayPath appendString:@" : "];
			[displayPath appendString:current];
		}
	}
	else if([[[value pathComponents] objectAtIndex:1] isEqual:@"Volumes"])
	{
		displayPath = [NSString stringWithFormat:@"Missing folder on Volume \"%@\"", 
			[[value pathComponents] objectAtIndex:2]];
	}
	else
	{
		displayPath = [NSString stringWithFormat:@"Missing folder on Volume %@",
			[[NSFileManager defaultManager] displayNameAtPath:@"/"]];
	}
	
	return displayPath;
}

@end
