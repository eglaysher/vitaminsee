/*
 *  FileView.h
 *  CQView
 *
 *  Created by Elliot on 3/6/05.
 *  Copyright 2005 __MyCompanyName__. All rights reserved.
 *
 */


@protocol FileView

-(void)setPluginLayer:(PluginLayer*)pl;

// Capabilities
-(BOOL)canSetCurrentDirectory;
-(BOOL)canGoEnclosingFolder;

-(void)setCurrentDirectory:(NSString*)directory;

// Files need to be added and removed from lists.
-(void)removeFile:(NSString*)path;
-(void)addFile:(NSString*)path;

// View that gets displayed on the left hand side
-(NSView*)view;

@end
