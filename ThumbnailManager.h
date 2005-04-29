/////////////////////////////////////////////////////////////////////////
// File:          $Name$
// Module:        Seperate thread for building of thumbnails.
// Part of:       VitaminSEE
//
// Revision:      $Revision$
// Last edited:   $Date$
// Author:        $Author$
// Copyright:     (c) 2005 Elliot Glaysher
// Created:       3/18/05
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

#import <pthread.h>

@class IconFamily;
@class VitaminSEEController;

@interface ThumbnailManager : NSObject {
	// TASK QUEUE:
	pthread_mutex_t taskQueueLock;
	NSMutableArray* thumbnailQueue;
	
	pthread_mutex_t imageScalingProperties;
		
	pthread_cond_t conditionLock;		
	
	NSImage* currentIconFamilyThumbnail;
	NSString* currentPath;
	int thumbnailLoadingPosition;
	
	id vitaminSEEController;
	
	bool shouldBuildIcon;
}

-(id)initWithController:(id)parrentController;


-(void)buildThumbnail:(NSString*)path;
-(void)clearThumbnailQueue;

-(void)setShouldBuildIcon:(BOOL)newShouldBuildIcon;
-(void)setThumbnailLoadingPosition:(int)newPosition;

-(NSString*)getCurrentPath;
-(NSImage*)getCurrentThumbnail;
-(void)clearThumbnailQueue;

@end
