//
//  ThumbnailManager.h
//  VitaminSEE
//
//  Created by Elliot Glaysher on 11/26/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

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

+(void)subscribe:(id)object toDirectory:(EGPath*)directory;
+(void)unsubscribe:(id)object fromDirectory:(EGPath*)directory;

/** Call this function to retrieve a thumbnail from the cache, loading it if it
 * isn't already in memory.
 */
+(NSImage*)getThumbnailFor:(EGPath*)path;

@end
