/////////////////////////////////////////////////////////////////////////
// File:          $Name$
// Module:        Format a filesize for display
// Part of:       VitaminSEE
//
// Revision:      $Revision$
// Last edited:   $Date$
// Author:        $Author$
// Copyright:     (c) 2005 Elliot Glaysher
// Created:       2/2/05
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

#import "FileSizeFormatter.h"

@implementation FileSizeFormatter

-(NSString*)stringForObjectValue:(id)obj
{
	long long bytes;
	
	if([obj isKindOfClass:[NSNumber class]])
		bytes = [obj longLongValue];
	else if([obj isKindOfClass:[NSString class]])
	{		
		// If we're passed a "none" placeholder, then use the placeholder...
		if([obj isEqualTo:@"---"])
		   return @"---";
		   
		bytes = [obj intValue];
	}
	else
		return nil;
	
	
	// If the file is empty, say so
	if(bytes == 0)
		return @"0 bytes";
	
	if(bytes < 1024)
		return [NSString stringWithFormat:@"%qi bytes", bytes];
	else if(bytes < 1048567)
		return [NSString stringWithFormat:@"%qi Kb", bytes/1024];
	else if(bytes < 1073741824)
		return [NSString stringWithFormat:@"%qi Mb", bytes/1048567];
	else
		return [NSString stringWithFormat:@"%qi Gb", bytes/1073741824];
}

-(BOOL)getObjectValue:(id *)obj forString:(NSString *)string 
	 errorDescription:(NSString **)error
{
	
}

-(NSAttributedString*)attributedStringForObjectValue:(id)anObject 
							   withDefaultAttributes:(NSDictionary*)attributes
{

	return [[[NSAttributedString alloc] 
		initWithString:[self stringForObjectValue:anObject] 
			attributes:attributes] autorelease];
}

@end
