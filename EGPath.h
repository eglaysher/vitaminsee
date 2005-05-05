//
//  EGPath.h
//  VitaminSEE
//
//  Created by Elliot Glaysher on 5/2/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface EGPath : NSObject {
}

+(id)root;
+(id)pathWithPath:(NSString*)path;

// The filename to display to the user
-(NSString*)displayName;
-(NSString*)fileSystemPath;

-(BOOL)exists;
-(BOOL)isDirectory;

// Items in the current directory
-(NSArray*)directoryContents;

// The icon for the computer
-(NSImage*)fileIcon;

// An NSArray of NSStrings that contain the display names for 
-(NSArray*)pathDisplayComponents;

// An NSArray of EGPaths that complement display components
-(NSArray*)pathComponents;

@end

@interface EGPathRoot : EGPath { }
+(id)root;
@end

@interface EGPathFilesystemPath : EGPath {
	NSString* fileSystemPath;
}
+(id)pathWithPath:(NSString*)path;
-(id)initWithPath:(NSString*)path;
@end