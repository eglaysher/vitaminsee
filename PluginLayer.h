//
//  PluginLayer.h
//  VitaminSEE
//
//  Created by Elliot on 4/7/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "VitaminSEEController+PluginLayer.h"

@class VitaminSEEController;

@interface PluginLayer : NSObject {
	VitaminSEEController* controller;
}

-(id)initWithController:(VitaminSEEController*)inController;
+(id)pluginLayerWithController:(VitaminSEEController*)inController;

// Metadata management functions (expand greatly!)
-(BOOL)supportsKeywords:(NSString*)file;
-(NSMutableArray*)getKeywordsFromFile:(NSString*)file;
-(void)setKeywords:(NSArray*)keywords forFile:(NSString*)file;

////////////////////////////////////////////////////// File Management functions
/*!
    @method		-currentFile    
    @abstract	Returns the name of the current file being viewed in 
				VitaminSEE's image pane.
*/
-(NSString*)currentFile;

/*!
    @method     -setCurrentFile:
	@param		file	The full path of the file to preload
    @abstract   Sets the file currently being viewed in the right pane.
    @discussion (comprehensive description)
*/
-(void)setCurrentFile:(NSString*)file;

/*!
	@method		-preloadFile:
	@param		file	The full path of the file to preload
	@abstract	Tells VitaminSEE to preload a file.
*/
-(void)preloadFile:(NSString*)file;

/*!
    @method		-deleteFile:
	@param		file	The full path to the file to be deleted
	@abstract	Deletes a file
*/
-(int)deleteFile:(NSString*)file;

/*!
    @method		-moveFile:to:
	@param		file		Full path of the file to be moved.
	@param		destination	Full path of the destination folder.
	@abstract Moves a file.
*/
-(int)moveFile:(NSString*)file to:(NSString*)destination;

/*!
    @method -copyFile:to:
	@param file Full path of the file to be moved.
	@param destination Full path of the destination folder.
	@abstract  Copies a file.
*/
-(int)copyFile:(NSString*)file to:(NSString*)destination;

/*!
    @method -renameFile:to:
    @abstract  Renames a file
	@param file The full path to the file being renamed.
	@param destination The new name of the file in the current path.
*/
-(BOOL)renameFile:(NSString*)file to:(NSString*)destination;

//////////////////////////////////////////////////////////// Thumbnail functions
/*!
    @method -generateThumbnailForFile:
    @abstract   Generates a thumbnail for a file
	@param path The full path of the file
*/
-(void)generateThumbnailForFile:(NSString*)path;

-(void)clearThumbnailQueue;

///////////////////////////////////////////////////////////////////// UI Control
/*!
    @method -startProgressIndicator
    @abstract Shows and starts spinning the NSProgressIndicator at the bottom
		right of the main window.
*/
-(void)startProgressIndicator;

/*!
    @method		-stopProgressIndicator    
    @abstract   Hides and stops the spinning of the NSProgressIndicator at the
				bottom right of the main window.
*/
-(void)stopProgressIndicator;

/*!
    @method     -pathManager
    @abstract   Returns an NSUndoManager that's connected to the back/forward
				items on the Go menu
*/
-(NSUndoManager*)pathManager;

-(NSUndoManager*)undoManager;

@end
