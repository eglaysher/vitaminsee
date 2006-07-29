/////////////////////////////////////////////////////////////////////////
// File:          $URL$
// Module:        Path abstractions
// Part of:       VitaminSEE
//
// Revision:      $Revision$
// Last edited:   $Date$
// Author:        $Author$
// Copyright:     (c) 2005 Elliot Glaysher
// Created:       5/2/05
//
/////////////////////////////////////////////////////////////////////////
//
// This program is free software; you can redistribute it and/or
// modify it under the terms of the GNU General Public License
// as published by the Free Software Foundation; either version 2
// of the License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program; if not, write to the Free Software
// Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
//
////////////////////////////////////////////////////////////////////////

#import <Cocoa/Cocoa.h>

@interface EGPath : NSObject <NSCopying> {
	ItemCount collationKeyLen;
	UCCollationValue* collationKey;
}
-(id)copyWithZone:(NSZone*)zone;

+(id)root;
+(id)pathWithPath:(NSString*)path;

-(id)pathByAppendingPathComponent:(NSString*)pathComponent;

-(NSData*)dataRepresentationOfPath;

// Build the Unichar string
-(void)buildCollationKey;
-(UCCollationValue*)collationKey;
-(ItemCount)collationKeyLen;

// The filename to display to the user
-(NSString*)displayName;
-(NSString*)fileSystemPath;

-(NSString*)fileName;

-(BOOL)isRoot;
-(BOOL)exists;
-(BOOL)isNaturalFile;
-(BOOL)isDirectory;

-(EGPath*)pathByDeletingLastPathComponent;

// Items in the current directory
-(NSArray*)directoryContents;

// The icon for the computer
-(NSImage*)fileIcon;

// An NSArray of NSStrings that contain the display names for 
-(NSArray*)pathDisplayComponents;

// An NSArray of EGPaths that complement display components
-(NSArray*)pathComponents;

// Checks to see if the current file is an image file.
-(BOOL)isImage;

-(NSImage*)iconImageOfSize:(NSSize)size;

-(BOOL)hasThumbnailIcon;

@end

@interface EGPathRoot : EGPath { }
+(id)root;
@end

@interface EGPathFilesystemPath : EGPath {
	NSString* fileSystemPath;
}

+(id)pathWithPath:(NSString*)path;
-(id)initWithPath:(NSString*)path;

-(id)pathByAppendingPathComponent:(NSString*)pathComponent;

@end