/////////////////////////////////////////////////////////////////////////
// File:          $URL$
// Module:        ValueTransformer that returns true or false on whether a 
//                directory exists or not.
// Part of:       VitaminSEE
//
// Revision:      $Revision$
// Last edited:   $Date$
// Author:        $Author$
// Copyright:     (c) 2005 Elliot Glaysher
// Created:       4/11/05
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


#import "PathExistsValueTransformer.h"
#import "NSString+FileTasks.h"

@implementation PathExistsValueTransformer
+(Class)transformedValueClass
{
	return [NSNumber class];
}

+(BOOL)allowsReverseTransformation
{
	return NO;
}

-(id)transformedValue:(id)value
{
	if([value isDir])
		return [NSNumber numberWithBool:YES];
	else
		return [NSNumber numberWithBool:NO];
}

@end
