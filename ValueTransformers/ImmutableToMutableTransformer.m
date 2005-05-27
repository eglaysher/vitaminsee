/////////////////////////////////////////////////////////////////////////
// File:          $Name$
// Module:        ValueTransformer that turns an immutable value into a mutable one
// Part of:       VitaminSEE
//
// Revision:      $Revision$
// Last edited:   $Date$
// Author:        $Author$
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
////////////////////////////////////////////////////////////////////////

// This is ripped off from somewhere but I don't remember. TODO: Find out where
// this was stollen from.

#import "ImmutableToMutableTransformer.h"


@implementation ImmutableToMutableTransformer

+(Class)transformedValueClass
{
	return [NSMutableArray class];
}

+(BOOL)allowsReverseTransformation
{
	return YES;
}

-(id)transformedValue:(id)value
{
	if(value == nil)
		return nil;
	
	NSMutableArray* array = [NSMutableArray arrayWithCapacity:[value count]];
	NSEnumerator* e = [value objectEnumerator];
	id object;
	while(object = [e nextObject])
		[array addObject:[[object mutableCopy] autorelease]];
			
	return array;
}

@end
