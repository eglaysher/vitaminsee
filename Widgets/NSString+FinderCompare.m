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

#import "NSString+FinderCompare.h"

@implementation NSString (FinderCompare)

const UCCollateOptions FinderLikeCompareOptions = 
	kUCCollateComposeInsensitiveMask | 	kUCCollateWidthInsensitiveMask |
	kUCCollateCaseInsensitiveMask | kUCCollateDigitsOverrideMask | 
	kUCCollateDigitsAsNumberMask| kUCCollatePunctuationSignificantMask;

/** Implements Finder-like sorting. This code was adapted from
 * http://www.cocoadev.com/index.pl?FilenamesArentStrings , where I went the
 * next step and implemented the suggestion about stack allocation.
 */
-(NSComparisonResult)finderCompare:(id)aString
{
	SInt32 compareResult;
	
	CFIndex lhsLen = [self length];;
    CFIndex rhsLen = [aString length];
	
	UniChar lhsBuf[lhsLen];
	UniChar rhsBuf[rhsLen];
	
	[self getCharacters:lhsBuf];
	[aString getCharacters:rhsBuf];
	
	(void) UCCompareTextDefault(FinderLikeCompareOptions, lhsBuf, lhsLen,
								rhsBuf, rhsLen, NULL, &compareResult);	
	
	return (CFComparisonResult) compareResult;
}

@end

/** Generalized finder compare that takes two UniChar strings.
 */
NSComparisonResult finderCompareUnichars(UniChar* lhs, CFIndex lhsLen,
										 UniChar* rhs, CFIndex rhsLen)
{
	SInt32 compareResult;
	(void) UCCompareTextDefault(FinderLikeCompareOptions, lhs, lhsLen,
								rhs, rhsLen, NULL, &compareResult);	
	
	return (CFComparisonResult) compareResult;	
}
