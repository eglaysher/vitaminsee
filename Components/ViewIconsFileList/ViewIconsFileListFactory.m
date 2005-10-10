//
//  ViewIconsFileViewFactory.m
//  Prototype
//
//  Created by Elliot Glaysher on 8/28/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "ViewIconsFileListFactory.h"
#import "ViewIconViewController.h"

@implementation ViewIconsFileListFactory

-(id<FileList>)build
{
	return [[ViewIconViewController alloc] init];
}

@end
