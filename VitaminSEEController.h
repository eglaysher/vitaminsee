/////////////////////////////////////////////////////////////////////////
// File:          $Name$
// Module:        Main Controller Class
// Part of:       VitaminSEE
//
// Revision:      $Revision$
// Last edited:   $Date$
// Author:        $Author$
// Copyright:     (c) 2005 Elliot Glaysher
// Created:       1/30/05
//
/////////////////////////////////////////////////////////////////////////
//
// This library is free software; you can redistribute it and/or
// modify it under the terms of the GNU Lesser General Public
// License as published by the Free Software Foundation; either
// version 2.1 of the License, or (at your option) any later version.
//  
// This library is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
// Lesser General Public License for more details.
//  
// You should have received a copy of the GNU Lesser General Public
// License along with this library; if not, write to the Free Software
// Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  
// USA
//
/////////////////////////////////////////////////////////////////////////


#import <Cocoa/Cocoa.h>

@class EGOpenWithMenuDelegate;
@class ImageTaskManager;
@class ThumbnailManager;
@class ViewIconViewController;
@class PointerWrapper;
@class SortManagerController;
@class SS_PrefsController;
@class FavoritesMenuDelegate;
@class RBSplitView;

@protocol ImageDisplayer 
-(void)displayImage;
-(void)setIcon;
-(void)displayImage;
-(void)setIcon;

// Progress indicator control
-(void)startProgressIndicator;
-(void)stopProgressIndicator;

-(void)setStatusText:(NSString*)statusText;
@end

/*!
	@class VitaminSEEController
	@abstract Main Controller
*/
@interface VitaminSEEController : NSObject <ImageDisplayer>
{
	IBOutlet NSWindow* mainVitaminSeeWindow;
	
	// Menu items we need to attatch items to
	IBOutlet NSMenuItem* computerFolderMenuItem;
	IBOutlet NSMenuItem* homeFolderMenuItem;
	IBOutlet NSMenuItem* pictureFolderMenuItem;
	IBOutlet NSMenuItem* favoritesMenuItem;
	FavoritesMenuDelegate* favoritesMenuDelegate;
	IBOutlet NSMenuItem* openWithMenuItem;
	EGOpenWithMenuDelegate* openWithMenuDelegate;
	
    IBOutlet NSImageView *imageViewer;
	IBOutlet NSTextField * fileSizeLabel;
	IBOutlet NSTextField * imageSizeLabel;
	IBOutlet NSWindow* viewerWindow;
	IBOutlet RBSplitView* splitView;
	IBOutlet NSScrollView* scrollView;

	NSCursor *handCursor;
	
	// File view components:
	IBOutlet NSView* currentFileViewHolder;
	
	ViewIconViewController* viewAsIconsController;

	IBOutlet NSProgressIndicator* progressIndicator;
	IBOutlet NSTextField * progressCurrentTask;
		
	// Actual application data--NOT OUTLETS!
	NSString* currentImageFile;

	// Scale data
	bool scaleProportionally;
	float scaleRatio;

	NSUndoManager* pathManager;
	
	// Other threads that do work for us.
	ImageTaskManager* imageTaskManager;
	ThumbnailManager* thumbnailManager;
	
	SS_PrefsController *prefs;	
	
	// Loaded plugins:
	NSMutableDictionary* loadedBasePlugins;
	NSMutableDictionary* loadedViewPlugins;
	NSMutableDictionary* loadedCurrentFilePlugins;

	NSString* tmpDestination;

	BOOL setPathForFirstTime;
}

-(void)displayAlert:(NSString*)message 
	informativeText:(NSString*)info 
		 helpAnchor:(NSString*)anchor;

-(id)loadComponentNamed:(NSString*)name fromBundle:(NSString*)path;

-(id)sortManagerController;
-(id)keywordManagerController;
-(id)gotoFolderController;
-(id)viewAsIconsControllerPlugin;
-(id)imageMetadataPlugin;

// Moving about in 
//- (void)setCurrentDirectory:(NSString*)newCurrentDirectory file:(NSString*)newCurrentFile;
- (void)setCurrentFile:(NSString*)newCurrentFile;
- (void)setPluginCurrentFileTo:(NSString*)newCurrentFile;
- (void)preloadFile:(NSString*)file;

// Changing the user interface
- (void)setViewAsView:(NSView*)viewToSet;

// Redraws the text
- (void)redraw;

// File menu options
-(IBAction)openFolder:(id)sender;
-(IBAction)fakeOpenWithMenuSelector:(id)sender;
-(IBAction)closeWindow:(id)sender;
-(IBAction)referesh:(id)sender;

// View menu options
-(IBAction)toggleFileList:(id)sender;
// ----------------------
-(IBAction)revealInFinder:(id)sender;
-(IBAction)viewInPreview:(id)sender;

// Go menu actions
-(IBAction)goNextFile:(id)sender;
-(IBAction)goPreviousFile:(id)sender;
// ----------------------
-(IBAction)goEnclosingFolder:(id)sender;
-(IBAction)goBack:(id)sender;
-(IBAction)goForward:(id)sender;
// ----------------------
-(IBAction)goToComputerFolder:(id)sender;
-(IBAction)goToHomeFolder:(id)sender;
-(IBAction)goToPicturesFolder:(id)sender;
// ----------------------
-(IBAction)fakeFavoritesMenuSelector:(id)sender;
// ----------------------
-(IBAction)goToFolder:(id)sender;
-(void)finishedGotoFolder:(NSString*)done;

-(IBAction)toggleVitaminSee:(id)sender;
-(IBAction)toggleSortManager:(id)sender;
-(IBAction)toggleKeywordManager:(id)sender;

-(IBAction)zoomIn:(id)sender;
-(IBAction)zoomOut:(id)sender;
-(IBAction)zoomToFit:(id)sender;
-(IBAction)actualSize:(id)sender;

// Window delegate method to redraw the image when we resize...
//- (void)windowDidResize:(NSNotification*)notification;
-(void)displayImage;
-(void)setIcon;
-(void)setStatusText:(NSString*)statusText;

// Progress indicator control
-(void)startProgressIndicator;
-(void)stopProgressIndicator;

-(IBAction)showPreferences:(id)sender;
-(IBAction)deleteFileClicked:(id)sender;

-(IBAction)showGPL:(id)sender;

-(IBAction)addCurrentDirectoryToFavorites:(id)sender;
-(BOOL)isInFavorites:(NSString*)path;

-(IBAction)toggleToolbarShown:(id)sender;
-(IBAction)runToolbarCustomizationPalette:(id)sender;
-(void)selectFirstResponder;

@end
