//
//  ViewerDocument.m
//  Prototype
//
//  Created by Elliot Glaysher on 8/11/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "ApplicationController.h"
#import "ViewerDocument.h"
#import "ComponentManager.h"
#import "ImageLoader.h"
#import "VitaminSEEWindowController.h"
#import "EGPath.h"
#import "NSString+FileTasks.h"

@implementation ViewerDocument

/** Default initializer. Really calls the initWithPath: initializer with 
 * whatever the default startup path is.
 */
-(id)init
{
	return [self initWithPath:[[NSUserDefaults standardUserDefaults]
		objectForKey:@"DefaultStartupPath"]];
}

-(void)dealloc
{
	NSLog(@"Document %@ dealloccated", documentID);
	[window release];
	[viewerNotifications release];
	[super dealloc];	
}

//-----------------------------------------------------------------------------

/** Initializer that takes a path, creates a normal ViewAsIcons fileList and 
 * displays the incoming path.
 *
 * @param path The directory to display
 */
-(id)initWithPath:(NSString*)path
{
	if(self = [super init])
	{		
		// Obtain a unique document ID from the Application controller
		documentID = [[ApplicationController controller] getNextAvailableID];
		[documentID retain];
		
		// We need a file list
		fileList = [[ComponentManager getFileListPluginNamed:@"ViewAsIcons"] build];
		NSLog(@"FILELIST: %@", fileList);
		[fileList setDelegate:self];


		window = [[VitaminSEEWindowController alloc] initWithFileList:fileList
													   document:self];
		NSLog(@"Window: %@", window);
		viewerNotifications = [[NSNotificationCenter alloc] init];

		[window showWindow:window];

		[fileList setDirectory:[EGPath pathWithPath:@"/Users/elliot/Pictures"]];
		
		// Do something to set the current path.
//		[self setDisplayedFileTo:@"/Users/elliot/Pictures/6b.jpg"];
		
		scaleRatio = 1.0f;
		scaleMode = SCALE_IMAGE_TO_FIT;
	}

	return self;
}

//-----------------------------------------------------------------------------

/** Returns the current documentID, a number unique across sessions that 
 * represents this ViewerDocument. This number is used to keep track of which
 * windows request what images by the ImageLoader so that the ImageLoader will
 * cancel old tasks when a new task from the same ViewerDocument is called.
 */
-(NSNumber*)documentID
{
	return documentID;
}

//----------------------------------------------------------------------------- 

/** Sets the file being displayed. Will spawn a task to the ImageLoader to 
 * load and scale the image. This method is usually called by the current 
 * fileList plugin.
 *
 * @param file EGPath pointing to the file to display.
 */
-(void)setDisplayedFileTo:(EGPath*)file
{
	[file retain];
	[currentFile release];
	currentFile = file;
	
	if([[file fileSystemPath] isImage]) {
		NSMutableDictionary* dic = [NSMutableDictionary 
			dictionaryWithObjectsAndKeys:
				scaleMode, @"Scale Mode",
				[NSNumber numberWithDouble:[window viewingAreaWidth]],
				@"Viewing Area Width",
				[NSNumber numberWithDouble:[window viewingAreaHeight]], 
				@"Viewing Area Height",
				HIGH_SMOOTHING, @"Smoothing",
				[NSNumber numberWithDouble:scaleRatio], @"Scale Ratio",
				currentFile, @"Path",
				self, @"Requester",
				nil];
		
		[ImageLoader loadTask:dic];
	}
}

//-----------------------------------------------------------------------------

/** Callback method used by the ImageLoader to actually set the image. 
 * ImageLoader is given tasks by the method setDisplayedFileTo:.
 */
-(void)receiveImage:(NSDictionary*)task
{
	// If this is still the current file (i.e., not stale...)
	if([[task objectForKey:@"Path"]  isEqual:currentFile]) {
		NSImage* image = [task objectForKey:@"Image"];
		if(image) {			
			// Set the image
			[window setImage:image];
			
			// Set the image size label
			[window setImageSizeLabelText:NSMakeSize(
				[[task objectForKey:@"Pixel Width"] floatValue],
				[[task objectForKey:@"Pixel Heigh"] floatValue])];
			
			// Set the size of the image in bytes
			[window setFileSizeLabelText:[[task objectForKey:@"Data Size"] 
				intValue]];	
		}
	}

	[task release];
}

//-----------------------------------------------------------------------------
 
/** Returns the current file being displayed.
 */
-(EGPath*)currentFile
{
	return currentFile;
}

//----------------------------------------------------------------------------- 

-(void)startProgressIndicator
{
	
}

//-----------------------------------------------------------------------------
 
-(void)stopProgressIndicator
{
	
}

-(void)actualSize:(id)sender
{
	NSLog(@"-actualSize:%@", sender);
	scaleMode = SCALE_IMAGE_PROPORTIONALLY;
	scaleRatio = 1.0f;
	
	// redraw
	[self setDisplayedFileTo:currentFile];
}

-(void)zoomIn:(id)sender
{
	NSLog(@"-zoomIn:%@", sender);
	
	// Add
	scaleMode = SCALE_IMAGE_PROPORTIONALLY;
	scaleRatio += 0.10f;
	[self setDisplayedFileTo:currentFile];	
}

-(void)zoomOut:(id)sender
{
	NSLog(@"-zoomOut:%@", sender);

	scaleMode = SCALE_IMAGE_PROPORTIONALLY;
	scaleRatio -= 0.10f;
	[self setDisplayedFileTo:currentFile];
}

-(void)zoomToFit:(id)sender
{
	NSLog(@"-zoomToFit:%@", sender);
	
	scaleMode = SCALE_IMAGE_TO_FIT;
	scaleRatio = 1.0f;
	[self setDisplayedFileTo:currentFile];
}

@end
