/* CQViewController */

#import <Cocoa/Cocoa.h>

@class ImageTaskManager;
@class ViewIconViewController;
@class PointerWrapper;
@class SortManagerController;
@class SS_PrefsController;

@protocol ImageDisplayer 
-(void)displayImage;
-(void)setIcon;
@end

/*!
	@class CQViewController
	@abstract Main Controller
*/
@interface CQViewController : NSObject <ImageDisplayer>
{
    IBOutlet NSImageView *imageViewer;
	IBOutlet NSTextField * fileSizeLabel;
	IBOutlet NSTextField * imageSizeLabel;
	IBOutlet NSWindow* viewerWindow;
	IBOutlet NSScrollView* scrollView;

	// Floating NSPanels
	IBOutlet NSPanel* sortingManager;
	SortManagerController* _sortManagerController;
	
	// Scale view controls
	IBOutlet NSView* scaleView;
	IBOutlet NSSlider* scaleSlider;

	// File view components:
	// * 
	IBOutlet NSPopUpButton* directoryDropdown;
	IBOutlet NSView* currentFileViewHolder;
	NSView* currentFileView;
	
	// * ViewAsImage specific components
	IBOutlet ViewIconViewController* viewAsIconsController;

	IBOutlet NSProgressIndicator* progressIndicator;
	IBOutlet NSTextField * progressCurrentTask;
		
	// Actual application data--NOT OUTLETS!
	NSImageRep* currentImageRep;
	NSString* currentImageFile;

	NSArray* currentDirectoryComponents;
	NSString* currentDirectory;

	// Scale data
//	ScalingMethod scaleMethod;
	bool scaleProportionally;
	float scaleRatio;

	NSUndoManager* pathManager;
	
	ImageTaskManager* imageTaskManager;
	
	SS_PrefsController *prefs;
}

-(NSWindowController*)sortManagerController;

// Moving about in 
- (void)setCurrentDirectory:(NSString*)newCurrentDirectory file:(NSString*)newCurrentFile;
- (void)setCurrentFile:(NSString*)newCurrentFile;
- (void)preloadFiles:(NSArray*)filesToPreload;

// Changing the user interface
- (void)setViewAsView:(NSView*)viewToSet;

// Redraws the text
- (void)redraw;

// Go menu actions
-(IBAction)goEnclosingFolder:(id)sender;
-(IBAction)goBack:(id)sender;
-(IBAction)goForward:(id)sender;


-(IBAction)showSortManager:(id)sender;

// Scaling stuff
- (IBAction)scaleView100Pressed:(id)sender;
- (IBAction)scaleViewPPressed:(id)sender;
- (IBAction)scaleViewSliderMoved:(id)sender;

-(void)zoomToFit:(id)sender;

// Window delegate method to redraw the image when we resize...
- (void)windowDidResize:(NSNotification*)notification;
-(void)displayImage;
-(void)setIcon;

// Progress indicator control
-(void)startProgressIndicator:(NSString*)statusText;
-(void)stopProgressIndicator;

-(IBAction)showPreferences:(id)sender;
@end
