//
//  Util.m
//  CQView
//
//  Created by Elliot on 2/6/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "Util.h"
#import "NSString+FileTasks.h"
#import <stdlib.h>

struct DS buildImageSize(int boxWidth, int boxHeight, int imageWidth, int imageHeight,
						 BOOL canScaleProportionally, float ratioToScale,
						 BOOL*canGetAwayWithQuickRender)
{
	NSLog(@"Going to build size with box:[%d,%d] image:[%d, %d] canScale:%d ratio:%f",
		  boxWidth, boxHeight, imageWidth, imageHeight, canScaleProportionally, ratioToScale);
	struct DS display;
	
	if(canScaleProportionally == YES)
	{
		// Set the size of the image to the size of the image scaled by our 
		// ratio and then tell the imageViewer to scale it to that size.
		display.width = imageWidth * ratioToScale;
		display.height = imageHeight * ratioToScale;
	}
	else
	{
		if(imageWidth <= boxWidth && imageHeight <= boxHeight)
		{
			display.width = imageWidth;
			display.height = imageHeight;
			*canGetAwayWithQuickRender = YES; 		
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

// FIXME: We need a working function to provide an image of files with crap...
// 
NSImage* buildImageFromNormalFile(NSString* path, NSSize size)
{
    NSImage *nodeImage = nil;
    
    nodeImage = [[NSWorkspace sharedWorkspace] iconForFile:path];
    if (!nodeImage) {
        // No icon for actual file, try the extension.
        nodeImage = [[NSWorkspace sharedWorkspace] iconForFileType:[path pathExtension]];
    }
    [nodeImage setSize: size];
	
	if ([path isLink]) {
        NSImage *arrowImage = [NSImage imageNamed: @"FSIconImage-LinkArrow"];
        NSImage *nodeImageWithArrow = [[[NSImage alloc] initWithSize: size] autorelease];
        
        [arrowImage setScalesWhenResized: YES];
        [arrowImage setSize: size];
        
        [nodeImageWithArrow lockFocus];
        [nodeImage compositeToPoint:NSZeroPoint operation:NSCompositeCopy];
        [arrowImage compositeToPoint:NSZeroPoint operation:NSCompositeSourceOver
			];
        [nodeImageWithArrow unlockFocus];
        
        nodeImage = nodeImageWithArrow;
    }
    
    if (nodeImage==nil) {
        nodeImage = [NSImage imageNamed:@"FSIconImage-Default"];
    }
    
    return nodeImage;
}