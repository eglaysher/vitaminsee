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

float buildRatio(float first, float second)
{
	float firstRatio = first / second;
	float secondRatio = second / first;
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