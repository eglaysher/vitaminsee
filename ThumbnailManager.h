/////////////////////////////////////////////////////////////////////////
// File:          $URL$
// Module:        Window object for a viewer window.
// Part of:       VitaminSEE
//
// ID:            $Id: ApplicationController.m 123 2005-04-18 00:21:02Z elliot $
// Revision:      $Revision$
// Last edited:   $Date$
// Author:        $Author$
// Copyright:     (c) 2005 Elliot Glaysher
// Created:       11/26/05
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

@class EGPath;

/** The ThumbnailManager class is responsible for loading, creating, and owning
 * all the thumbnails. The ThumbnailManager works on a subscription model; 
 * various viewer windows "subscribe" to a directory. This will start loading
 * the thumbnails for all 
 *
 */
@interface ThumbnailManager : NSObject {

}

+(void)updatePreferences;
+(BOOL)getGenerateThumbnails;

+(void)subscribe:(id)object toDirectory:(EGPath*)directory;
+(void)unsubscribe:(id)object fromDirectory:(EGPath*)directory;

/** Call this function to retrieve a thumbnail from the cache, loading it if it
 * isn't already in memory.
 */
+(NSImage*)getThumbnailFor:(EGPath*)path;

@end
