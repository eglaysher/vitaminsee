/////////////////////////////////////////////////////////////////////////
// File:          $URL: http://svn.elliotglaysher.org/VitaminSEE/trunk/Widgets/EGPath.m $
// Module:        Finder-like sorting
// Part of:       VitaminSEE
//
// Revision:      $Revision: 440 $
// Last edited:   $Date: 2006-03-25 13:45:42 -0600 (Sat, 25 Mar 2006) $
// Author:        $Author: eglaysher $
// Copyright:     (c) 2005 Elliot Glaysher
// Created:       6/10/06
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

@interface NSString (FinderCompare)
+(UCCollateOptions)finderLikeCollateOptions;
-(NSComparisonResult)finderCompare:(id)object;
@end

NSComparisonResult finderCompareUnichars(UniChar* lhs, CFIndex lhsLen,
										 UniChar* rhs, CFIndex rhsLen);
NSComparisonResult finderCompareCollations(const UCCollationValue * lhs,
										   ItemCount lhsLen,
										   const UCCollationValue * rhs,
										   ItemCount rhsLen);
