/////////////////////////////////////////////////////////////////////////
// File:          $URL$
// Module:        NSWindowController subclass for the floating FileList
// Part of:       VitaminSEE
//
// Revision:      $Revision$
// Last edited:   $Date$
// Author:        $Author$
// Copyright:     (c) 2006 Elliot Glaysher
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
// Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 
// 02110-1301, USA.
//
////////////////////////////////////////////////////////////////////////


#import "FileListWindowController.h"
#import "AppKitAdditions.h"

@implementation FileListWindowController

-(id)init
{	
	currentlyAnimated = NO;
	return [super initWithWindowNibName:@"FileList"];
}

//-----------------------------------------------------------------------------

-(void)awakeFromNib
{
	// Don't cascade windows so that autosave positioning works correctly.
	[self setShouldCascadeWindows:NO];
}

//-----------------------------------------------------------------------------

/** Make the window display in the correct location.
 */
-(void)windowDidLoad
{
	[super windowDidLoad];
	[self setWindowFrameAutosaveName:@"FullScreenFileList"];
	
	// Prevent the zoom button from displaying; I am 100% sure that the user
	// does not mean to hit it, and the resulting window would be confusing.
	[[[self window] standardWindowButton:NSWindowZoomButton] setEnabled:NO];
}

//-----------------------------------------------------------------------------

/** Give the fileList focus when 
 */ 
- (IBAction)showWindow:(id)sender
{
	[super showWindow:self];
	
	// 
	[fileList makeFirstResponderTo:[self window]];
}

//-----------------------------------------------------------------------------

-(void)beginCountdownToDisplayProgressIndicator
{
	[NSObject cancelPreviousPerformRequestsWithTarget:self
											 selector:@selector(startProgressIndicator)
											   object:nil];
	[self performSelector:@selector(startProgressIndicator)
			   withObject:nil
			   afterDelay:0.10];
}

//-----------------------------------------------------------------------------

-(void)cancelCountdown
{
	[NSObject cancelPreviousPerformRequestsWithTarget:self
											 selector:@selector(startProgressIndicator)
											   object:nil];		
}

//-----------------------------------------------------------------------------

// Progress indicator control
-(void)startProgressIndicator
{
	if(!currentlyAnimated)
	{
		[progressIndicator startAnimation:self];		
		currentlyAnimated = true;
	}
}

//-----------------------------------------------------------------------------

-(void)stopProgressIndicator
{
	[self cancelCountdown];
	
	if(currentlyAnimated) 
	{
		[progressIndicator stopAnimation:self];
		currentlyAnimated = false;
	}
}

//-----------------------------------------------------------------------------

-(void)setFileList:(id<FileList>)newList
{
	fileList = newList;
	
	id fileListView = [fileList getView];
	[currentFileViewHolder setSubview:fileListView];	
}

//-----------------------------------------------------------------------------

-(void)setFileSizeLabelText:(int)fileSize 
{
	if(fileSize == -1)
		[fileSizeLabel setObjectValue:@"---"];
	else
		[fileSizeLabel setObjectValue:[NSNumber numberWithInt:fileSize]];	
}

//-----------------------------------------------------------------------------

-(void)setImageSizeLabelText:(NSSize)size 
{
	// Truncate the size in pixels for display
	int width = size.width;
	int height = size.height;
	
	if(width == 0 && height == 0)
		[imageSizeLabel setStringValue:@"---"];
	else
		[imageSizeLabel setStringValue:[NSString stringWithFormat:@"%i x %i", 
			width, height]];	
}

@end
