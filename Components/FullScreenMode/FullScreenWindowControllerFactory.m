//
//  FullScreenWindowControllerFactory.m
//  VitaminSEE
//
//  Created by Elliot on 2/24/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "FullScreenWindowControllerFactory.h"
#import "FullScreenWindowController.h"

@implementation FullScreenWindowControllerFactory

-(id)build
{
	return [[FullscreenWindowController alloc] init];
}

@end
