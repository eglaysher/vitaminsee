//
//  FSBrowserCell.h
//
//  Copyright (c) 2001-2002, Apple. All rights reserved.
//
//  FSBrowserCell knows how to display file system info obtained from an FSNodeInfo object.

#import <Cocoa/Cocoa.h>

@class FSNodeInfo;

@interface FSBrowserCell : NSBrowserCell { 
@private
    NSImage *iconImage;
	NSString *path;
	FSNodeInfo *infoNode;
}

- (void)setAttributedStringValueFromFSNodeInfo:(FSNodeInfo*)node;
- (void)setIconImage: (NSImage *)image;
- (NSImage*)iconImage;
- (NSString*)absolutePath;
- (FSNodeInfo*)nodeInfo;
@end

