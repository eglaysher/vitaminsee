/////////////////////////////////////////////////////////////////////////
// File:          $Name$
// Module:        Scroll View that can become key, processes key input as
//                scrolling, and draws a focus ring.
// Part of:       VitaminSEE
//
// Revision:      $Revision: 192 $
// Last edited:   $Date: 2005-05-18 01:07:24 -0400 (Wed, 18 May 2005) $
// Author:        $Author: glaysher $
// Copyright:     (c) 2005 Elliot Glaysher
// Created:       5/11/05
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

#import <Cocoa/Cocoa.h>


@interface EGScrollView : NSScrollView {
	BOOL shouldDrawFocusRing; 
    NSResponder *lastResp;
}

-(void)noteMouseDown;
-(void)scrollTheViewByX:(float)x y:(float)y;
@end
