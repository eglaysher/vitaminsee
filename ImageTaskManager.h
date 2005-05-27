/////////////////////////////////////////////////////////////////////////
// File:          $Name$
// Module:        Loads and preloads images in a seperate thread and passes them
//                off to the main thread
// Part of:       VitaminSEE
//
// Revision:      $Revision$
// Last edited:   $Date$
// Author:        $Author$
// Copyright:     (c) 2005 Elliot Glaysher
// Created:       2/7/05
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

#import <pthread.h>

@class IconFamily;
@class VitaminSEEController;

@protocol ImageTaskProtocol
-(oneway void)displayImageWithPath:(in NSString*)path;
-(oneway void)preloadImage:(in NSString*)path;
-(oneway void)displayImageWithPath:(in NSString*)newImageFile
						 smoothing:(in int)newSmoothing
			   scaleProportionally:(in BOOL)newScaleProportionally
						scaleRatio:(in float)newScaleRatio
				   contentViewSize:(in NSSize)newContentViewSize;
@end

@interface ImageTaskManager : NSObject <ImageTaskProtocol> {
	// TASK QUEUE:
	pthread_mutex_t taskQueueLock;
	NSString* fileToDisplayPath;
	NSMutableArray* preloadQueue;
	
	pthread_mutex_t imageCacheLock;
	NSMutableDictionary* imageCache;
	
	pthread_cond_t conditionLock;
	
	NSSize contentViewSize;
	float scaleRatio;
	BOOL scaleProportionally;
	int smoothing;
	pthread_mutex_t imageScalingProperties;
	
	NSImage* currentImage;
	int currentImageWidth;
	int currentImageHeight;
	float currentImageScale;
	
	NSImage* currentIconFamilyThumbnail;
	id currentIconCell;
	int thumbnailLoadingPosition;
	
	id vitaminSEEController;
}

-(id)initWithController:(id)controller;

-(oneway void)displayImageWithPath:(in NSString*)path;
-(oneway void)preloadImage:(in NSString*)path;
-(oneway void)displayImageWithPath:(in NSString*)newImageFile
						 smoothing:(in int)newSmoothing
			   scaleProportionally:(in BOOL)newScaleProportionally
						scaleRatio:(in float)newScaleRatio
				   contentViewSize:(in NSSize)newContentViewSize;

-(void)setSmoothing:(int)newSmoothing;
-(void)setScaleRatio:(float)newScaleRatio;
-(void)setScaleProportionally:(BOOL)newScaleProportionally;
-(void)setContentViewSize:(NSSize)newContentViewSize;

-(NSImage*)getCurrentImageWithWidth:(int*)width height:(int*)height scale:(float*)scale;

@end
