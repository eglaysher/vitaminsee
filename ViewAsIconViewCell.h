//
//  ViewAsIconViewCell.h
//  CQView
//
//  Created by Elliot on 2/9/05.
//  Copyright 2005 Elliot Glaysher. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class ImageTaskManager;

@interface ViewAsIconViewCell : NSBrowserCell {
	NSString* title;
	BOOL selected;

	NSImage* iconImage;
	NSString* thisCellsFullPath;	

	float cachedTitleWidth;
	NSString* cachedCellTitle;
}

-(void)setCellPropertiesFromPath:(NSString*)path;
-(void)setIconImage:(NSImage*)image;
-(NSString*)cellPath;

-(void)setTitle:(NSString*)newTitle;

-(void)resetTitleCache;
@end
