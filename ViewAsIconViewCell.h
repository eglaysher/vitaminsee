//
//  ViewAsIconViewCell.h
//  CQView
//
//  Created by Elliot on 2/9/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class ImageTaskManager;

@interface ViewAsIconViewCell : NSBrowserCell {
	NSString* title;
	BOOL selected;

	NSImage* iconImage;
	NSString* thisCellsFullPath;	
}

-(void)setCellPropertiesFromPath:(NSString*)path;
-(void)setIconImage:(NSImage*)image;
-(NSString*)cellPath;

-(void)setTitle:(NSString*)newTitle;

@end
