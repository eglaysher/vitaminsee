//
//  ViewAsIconViewCell.m
//  CQView
//
//  Created by Elliot on 2/9/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "ViewAsIconViewCell.h"
#import "NSString+FileTasks.h"

@implementation ViewAsIconViewCell

-(void)dealloc
{
	[thisCellsFullPath release];
}

-(NSString*)cellPath
{
	return thisCellsFullPath;
}

-(void)setCellPropertiesFromPath:(NSString*)path
{
	// Keep this path...
	[thisCellsFullPath release];
	[path retain];
	thisCellsFullPath = path;

	[self setStringValue:[thisCellsFullPath lastPathComponent]];
	
	// We are going to have to do something with images here...
	[self setEnabled:[thisCellsFullPath isReadable]];
	
	// In the ViewAsIconView, there are no left directories...
	[self setLeaf:YES]; 
}

@end
