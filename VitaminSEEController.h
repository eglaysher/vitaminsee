/* VitaminSEEController */

#import <Cocoa/Cocoa.h>

@class ImageTaskManager;
@class ThumbnailManager;
@class ViewIconViewController;
@class PointerWrapper;
@class SortManagerController;
@class SS_PrefsController;

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

/* Plugin dictionary structure
 {
	'PluginName' => id
 }

 */

/*!
	@class VitaminSEEController
	@abstract Main Controller
*/
@interface VitaminSEEController : NSObject <ImageDisplayer>
{
	IBOutlet NSWindow* mainVitaminSeeWindow;
	
	// Menu items we need to attatch items to
	IBOutlet NSMenuItem* homeFolderMenuItem;
	IBOutlet NSMenuItem* pictureFolderMenuItem;
	
    IBOutlet NSImageView *imageViewer;
	IBOutlet NSTextField * fileSizeLabel;
	IBOutlet NSTextField * imageSizeLabel;
	IBOutlet NSWindow* viewerWindow;
	IBOutlet NSScrollView* scrollView;

	// File view components:
	IBOutlet NSPopUpButton* directoryDropdown;
	IBOutlet NSView* currentFileViewHolder;
	NSView* currentFileView;
	
	// * ViewAsImage specific components
	IBOutlet ViewIconViewController* viewAsIconsController;

	IBOutlet NSProgressIndicator* progressIndicator;
	IBOutlet NSTextField * progressCurrentTask;
		
	// Actual application data--NOT OUTLETS!
//	NSImageRep* currentImageRep;
	NSString* currentImageFile;

	NSArray* currentDirectoryComponents;
	NSString* currentDirectory;

	// Scale data
	bool scaleProportionally;
	float scaleRatio;

	NSUndoManager* pathManager;
	
	// Other threads that do work for us.
	ImageTaskManager* imageTaskManager;
	ThumbnailManager* thumbnailManager;
	
	SS_PrefsController *prefs;	
	
	// Loaded plugins:
	NSMutableArray* loadedFilePlugins;	

	// Integrated plugins.
	id _sortManagerController;
	id _keywordManagerController;
	id _gotoFolderController;	
}

-(void)displayAlert:(NSString*)message 
	informativeText:(NSString*)info 
		 helpAnchor:(NSString*)anchor;

-(id)loadComponentFromBundle:(NSString*)path;

-(id)sortManagerController;
-(id)keywordManagerController;
-(id)gotoFolderController;

// Moving about in 
- (void)setCurrentDirectory:(NSString*)newCurrentDirectory file:(NSString*)newCurrentFile;
- (void)setCurrentFile:(NSString*)newCurrentFile;
- (void)preloadFiles:(NSArray*)filesToPreload;

// Changing the user interface
- (void)setViewAsView:(NSView*)viewToSet;

// Redraws the text
- (void)redraw;

// File menu options
-(IBAction)openFolder:(id)sender;
-(IBAction)closeWindow:(id)sender;
-(IBAction)referesh:(id)sender;

// View menu options
-(IBAction)revealInFinder:(id)sender;
-(IBAction)viewInPreview:(id)sender;

// Go menu actions
-(IBAction)goEnclosingFolder:(id)sender;
-(IBAction)goBack:(id)sender;
-(IBAction)goForward:(id)sender;
// ----------------------
-(IBAction)goToHomeFolder:(id)sender;
-(IBAction)goToPicturesFolder:(id)sender;
// ----------------------
-(IBAction)goToFolder:(id)sender;

-(IBAction)toggleVitaminSee:(id)sender;
-(IBAction)toggleSortManager:(id)sender;
-(IBAction)toggleKeywordManager:(id)sender;

-(IBAction)zoomIn:(id)sender;
-(IBAction)zoomOut:(id)sender;
-(IBAction)zoomToFit:(id)sender;
-(IBAction)actualSize:(id)sender;

// Window delegate method to redraw the image when we resize...
- (void)windowDidResize:(NSNotification*)notification;
-(void)displayImage;
-(void)setIcon;
-(void)setStatusText:(NSString*)statusText;

// Progress indicator control
-(void)startProgressIndicator;
-(void)stopProgressIndicator;

-(IBAction)showPreferences:(id)sender;
-(IBAction)deleteFileClicked:(id)sender;

-(IBAction)showGPL:(id)sender;
@end
