/////////////////////////////////////////////////////////////////////////
// File:          $Name$
// Module:        Path abstractions
// Part of:       VitaminSEE
//
// Revision:      $Revision: 192 $
// Last edited:   $Date: 2005-05-18 01:07:24 -0400 (Wed, 18 May 2005) $
// Author:        $Author: glaysher $
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

@interface EGPath : NSObject {
}

+(id)root;
+(id)pathWithPath:(NSString*)path;

// The filename to display to the user
-(NSString*)displayName;
-(NSString*)fileSystemPath;

-(BOOL)isRoot;

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