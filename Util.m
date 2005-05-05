/////////////////////////////////////////////////////////////////////////
// File:          $Name$
// Module:        Utility functions
// Part of:       VitaminSEE
//
// Revision:      $Revision$
// Last edited:   $Date$
// Author:        $Author$
// Copyright:     (c) 2005 Elliot Glaysher
// Created:       2/6/05
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


#import "Util.h"
#import "NSString+FileTasks.h"
#import <stdlib.h>

NSImageRep* loadImage(NSString* path)
{
	NSData* imageData = [NSData dataWithContentsOfFile:path];

	// Get the class that can handle this file.
	Class imageRepClass = [NSImageRep imageRepClassForData:imageData];
	if(!imageRepClass)
		return nil;
	
	id imageRep = [[imageRepClass alloc] initWithData:imageData];
	NSLog(@"image rep retain count in loadImage: %d", [imageRep retainCount]);

	// 
	return [imageRep autorelease];
}

struct DS buildImageSize(int boxWidth, int boxHeight, int imageWidth, int imageHeight,
						 BOOL canScaleProportionally, float ratioToScale,
						 BOOL*canGetAwayWithQuickRender, float* ratioUsed)
{
	struct DS display;
	
	if(canScaleProportionally == YES)
	{
		// Set the size of the image to the size of the image scaled by our 
		// ratio and then tell the imageViewer to scale it to that size.
		display.width = imageWidth * ratioToScale;
		display.height = imageHeight * ratioToScale;
		*ratioUsed = ratioToScale;
	}
	else
	{
		if(imageWidth <= boxWidth && imageHeight <= boxHeight)
		{
			display.width = imageWidth;
			display.height = imageHeight;
			*canGetAwayWithQuickRender = YES; 		
			*ratioUsed = 1.0;
		}
		else
		{
			float heightRatio = buildRatio(boxHeight, imageHeight);
			float widthRatio = buildRatio(boxWidth, imageWidth);
			canGetAwayWithQuickRender = NO;
			
			// The image needs to be scaled to fit in the box. Go through the
			// two possible ratios in terms of biggest first and check to
			// see if they work. We sort an array of the two values so we make
			// sure we aren't scaling smaller then what can be displayed on the
			// screen
			//
			// Note to self: It's nonobvious, but fhe following is NOT equivlent to:
			//    min(heightRatio, widthRatio);.
			// This block finds the maximum safe scaleing ratio. Finding the minimum
			// ratio will result in poorly scaled pictures sometimes...
			NSMutableArray* ratios = [NSMutableArray arrayWithObjects:[NSNumber 
			numberWithFloat:heightRatio], [NSNumber numberWithFloat:widthRatio],
				nil];
			[ratios sortUsingSelector:@selector(compare:)];
			NSEnumerator* e = [ratios reverseObjectEnumerator];
			NSNumber* num;
			while(num = [e nextObject])
			{
				float ratio = [num floatValue];
				//				NSLog(@"Current ratio: %f", ratio);
				if((int)(imageWidth * ratio) <= boxWidth &&
				   (int)(imageHeight * ratio) <= boxHeight)
				{
					// We've found the ratio to use. Get out of this loop...
					display.width = imageWidth * ratio;
					display.height = imageHeight * ratio;
					*ratioUsed = ratio;
					break;
				}
			}		
		}	
	}	
	return display;
}

float buildRatio(int first, int second)
{
	float firstRatio = (float)(first) / (float)(second);
	float secondRatio = (float)(second) / (float)(first);
	return min(secondRatio, firstRatio);
}

BOOL imageRepIsAnimated(NSImageRep* rep)
{
	if([rep isKindOfClass:[NSBitmapImageRep class]] &&
	   [[(NSBitmapImageRep*)rep valueForProperty:NSImageFrameCount] intValue] > 1)
		return YES;
	else
		return NO;
}
