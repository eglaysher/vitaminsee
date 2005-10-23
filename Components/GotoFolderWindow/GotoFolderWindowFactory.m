//
//  GotoFolderSheetFactory.m
//  VitaminSEE
//
//  Created by Elliot Glaysher on 10/23/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "GotoFolderWindowFactory.h"
#import "GotoFolderWindowController.h"

@implementation GotoFolderWindowFactory

-(id)build 
{
	return [[GotoFolderWindowController alloc] init];
}

@end
