//
//  GotoFolderSheetFactory.m
//  VitaminSEE
//
//  Created by Elliot Glaysher on 10/23/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "GotoFolderSheetFactory.h"
#import "GotoFolderSheetController.h"

@implementation GotoFolderSheetFactory

-(id)build 
{
	return [[GotoFolderSheetController alloc] init];
}

@end
