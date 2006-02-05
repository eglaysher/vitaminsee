/////////////////////////////////////////////////////////////////////////
// File:          $Name$
// Module:        Loads images in a seperate thread.
// Part of:       VitaminSEE
//
// ID:            $Id: ApplicationController.m 123 2005-04-18 00:21:02Z elliot $
// Revision:      $Revision: 248 $
// Last edited:   $Date: 2005-07-13 20:26:59 -0500 (Wed, 13 Jul 2005) $
// Author:        $Author: elliot $
// Copyright:     (c) 2005 Elliot Glaysher
// Created:       9/13/05
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

extern NSString* SCALE_IMAGE_PROPORTIONALLY;
extern NSString* SCALE_IMAGE_TO_FIT;
extern NSString* SCALE_IMAGE_TO_FIT_WIDTH;
extern NSString* SCALE_IMAGE_TO_FIT_HEIGHT;

extern NSString* NO_SMOOTHING;
extern NSString* LOW_SMOOTHING;
extern NSString* HIGH_SMOOTHING;

@class EGPath;

@interface ImageLoader : NSObject {
}

+(void)loadTask:(NSMutableDictionary*)task;
+(void)preloadImage:(EGPath*)file;
@end
