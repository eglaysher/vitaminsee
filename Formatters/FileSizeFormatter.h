/////////////////////////////////////////////////////////////////////////
// File:          $URL$
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

#import <Cocoa/Cocoa.h>


@interface FileSizeFormatter : NSFormatter {
}

// The three things you need to override...
-(NSString*)stringForObjectValue:(id)obj;
//-(BOOL)getObjectValue:(id *)obj forString:(NSString *)string 
//	 errorDescription:(NSString **)error;
//-(NSAttributedString*)attributedStringForObjectValue:(id)anObject 
//							   withDefaultAttributes:(NSDictionary*)attributes;

@end
