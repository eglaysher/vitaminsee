//
//  ViewAsIconViewCell.h
//  CQView
//
//  Created by Elliot on 2/9/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface ViewAsIconViewCell : NSBrowserCell {
	NSImage* iconImage;
	NSString* thisCellsFullPath;	
}

-(void)setCellPropertiesFromPath:(NSString*)path;
-(NSString*)cellPath;

@end
