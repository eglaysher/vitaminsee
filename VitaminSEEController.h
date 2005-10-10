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

	// Open With Menu that needs initialization
	EGOpenWithMenuDelegate* openWithMenuDelegate;
	BOOL loadedOpenWithMenu;

	NSMutableArray* pictureViewers;
	
	SS_PrefsController *prefs;	
	
	// Loaded plugins:
	NSMutableDictionary* loadedBasePlugins;
	NSMutableDictionary* loadedViewPlugins;
	NSMutableDictionary* loadedCurrentFilePlugins;

	NSString* tmpDestination;

	BOOL setPathForFirstTime;
}

//-(void)displayAlert:(NSString*)message 
//	informativeText:(NSString*)info 
//		 helpAnchor:(NSString*)anchor;


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

-(IBAction)toggleVitaminSee:(id)sender;
-(IBAction)toggleSortManager:(id)sender;
-(IBAction)toggleKeywordManager:(id)sender;

// Window delegate method to redraw the image when we resize...
//- (void)windowDidResize:(NSNotification*)notification;
-(void)displayImage;
-(void)setIcon;
-(void)setStatusText:(NSString*)statusText;

// Progress indicator control

-(IBAction)showPreferences:(id)sender;

-(IBAction)showGPL:(id)sender;

-(BOOL)isInFavorites:(NSString*)path;

//-(IBAction)toggleToolbarShown:(id)sender;
//-(IBAction)runToolbarCustomizationPalette:(id)sender;
//-(void)selectFirstResponder;

//-(IBAction)setImageAsDesktop:(id)sender;

-(IBAction)newWindow:(id)sender;

@end
