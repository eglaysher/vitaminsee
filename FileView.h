/*
 *  FileView.h
 *  CQView
 *
 *  Created by Elliot on 3/6/05.
 *  Copyright 2005 __MyCompanyName__. All rights reserved.
 *
 */


@protocol FileView

-(void)fileSetTo:(NSString*)newFile;

-(NSView*)view;


// Things for the go menu
-(BOOL)canGoEnclosingFolder;

@end
