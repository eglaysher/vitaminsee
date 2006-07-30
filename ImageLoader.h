/////////////////////////////////////////////////////////////////////////
// File:          $URL$
// Module:        Loads images in a seperate thread.
// Part of:       VitaminSEE
//
// ID:            $Id: ApplicationController.m 123 2005-04-18 00:21:02Z elliot $
// Revision:      $Revision$
// Last edited:   $Date$
// Author:        $Author$
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

// Scale value constants
extern NSString* SCALE_IMAGE_PROPORTIONALLY;
extern NSString* SCALE_IMAGE_TO_FIT;
extern NSString* SCALE_IMAGE_TO_FIT_WIDTH;
extern NSString* SCALE_IMAGE_TO_FIT_HEIGHT;

// Smoothing value constants
extern NSString* NO_SMOOTHING;
extern NSString* LOW_SMOOTHING;
extern NSString* HIGH_SMOOTHING;

// ImageLoader structure constants
extern NSString* IL_REQUESTER;
extern NSString* IL_PATH;
extern NSString* IL_PARTIAL;
extern NSString* IL_SCALE_MODE;
extern NSString* IL_VIEWING_AREA_HEIGHT;
extern NSString* IL_VIEWING_AREA_WIDTH;
extern NSString* IL_SMOOTHING;
extern NSString* IL_IMAGE;
extern NSString* IL_PIXEL_WIDTH;
extern NSString* IL_PIXEL_HEIGHT;
extern NSString* IL_SCALE_RATIO;

extern NSString* IL_DATE;
extern NSString* IL_IMAGE_REP;
extern NSString* IL_DATA_SIZE;

@class EGPath;

@interface ImageLoader : NSObject {
}

+(void)loadTask:(NSMutableDictionary*)task;
+(void)preloadImage:(EGPath*)file;
+(void)unregisterRequester:(id)requester;
+(void)clearAllCaches;

// Functions used in unit testing.
+(NSArray*)imagesInCache;

@end
