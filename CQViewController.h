/* CQViewController */

#import <Cocoa/Cocoa.h>

/*!
	@class CQViewController
	@abstract Main Controller
*/
@interface CQViewController : NSObject
{
    IBOutlet NSBrowser *browser;
    IBOutlet NSImageView *imageViewer;
	IBOutlet NSView *infoView;
	IBOutlet NSTextField * fileSizeLabel;
	IBOutlet NSTextField * imageSizeLabel;
	IBOutlet NSWindow* viewerWindow;
	IBOutlet NSScrollView* scrollView;

	// Scale view controls
	IBOutlet NSView* scaleView;
	IBOutlet NSSlider* scaleSlider;
	
	// Actual application data--NOT OUTLETS!
	NSImageRep* currentImageRep;
	
	// Scale data
	bool scaleProportionally;
	float scaleRatio;
}

/*!
	@method browserSingleClik:
	@abstract Called when a file is selected from the browser.
	@discussion This function is called when a file is selected in the browser.
		It	is then required that 
 */
-(IBAction)browserSingleClick:(id)browser;

-(void)redraw;

- (IBAction)scaleView100Pressed:(id)sender;
- (IBAction)scaleViewPPressed:(id)sender;
- (IBAction)scaleViewSliderMoved:(id)sender;
@end
