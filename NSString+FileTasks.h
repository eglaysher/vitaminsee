//
//  NSString+FileTasks.h
//  CQView
//
//  Created by Elliot on 2/9/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSString (FileTasks)
-(BOOL)isDir;
-(BOOL)isImage;
-(BOOL)isVisible;
-(BOOL)isReadable;
-(BOOL)isLink;
-(int)fileSize;
//-(NSString*)fileWithPath:(NSString*)containingDirectory;
- (NSImage*)iconImageOfSize:(NSSize)size;
@end
