//
//  ViewAsIconViewCell.m
//  CQView
//
//  Created by Elliot on 2/9/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "ViewAsIconViewCell.h"
#import "NSAttributedString+Truncation.h"
#import "NSString+FileTasks.h"


#define ICON_INSET_VERT		2.0	/* The size of empty space between the icon end the top/bottom of the cell */ 
#define ICON_SIZE 		128.0	/* Our Icons are ICON_SIZE x ICON_SIZE */
#define ICON_INSET_HORIZ	4.0	/* Distance to inset the icon from the left edge. */
#define ICON_TEXT_SPACING	2.0	/* Distance between the end of the icon and the text part */


@implementation ViewAsIconViewCell

-(id)init
{
	if(self = [super init])
	{
		iconImage = nil;
		[self setWraps:YES];
		[self setAlignment:NSCenterTextAlignment];
	}
	return self;
}

-(void)dealloc
{
	[title release];
	[iconImage release];
	[thisCellsFullPath release];
}

-(NSString*)cellPath
{
	return thisCellsFullPath;
}

-(void)setTitle:(NSString*)newTitle
{
	[title release];
	title = newTitle;
	[title retain];
}

-(void)setCellPropertiesFromPath:(NSString*)path
{
	// Keep this path...
	[thisCellsFullPath release];
	[path retain];
	thisCellsFullPath = path;
	
	[title release];
	title = [path lastPathComponent];
	[title retain];

	[self setStringValue:[thisCellsFullPath lastPathComponent]];
	
	if([path isDir])
		[self setIconImage:[[NSWorkspace sharedWorkspace] iconForFileType:
			NSFileTypeForHFSTypeCode(kGenericFolderIcon)]];
	else
		[self setIconImage:[[NSWorkspace sharedWorkspace] iconForFileType:
			[path pathExtension]]];
	
	// We are going to have to do something with images here...
	[self setEnabled:[thisCellsFullPath isReadable]];
	
	// In the ViewAsIconView, there are no left directories...
	[self setLeaf:YES]; 
	
//	// Allow editing of the cell...
//	[self setCellAttribute:NSCellEditable to:YES];
}

- (void)setIconImage:(NSImage*)image {
    [iconImage release];
    iconImage = image;
	[iconImage retain];
    
    // Make sure the image is going to display at the size we want.
    [iconImage setSize: NSMakeSize(ICON_SIZE,ICON_SIZE)];
}

- (NSImage*)iconImage {
    return iconImage;
}

-(void)setHighlighted:(BOOL)flag
{
	NSLog(@"Setting highlight!");
	[super setHighlighted:flag];
	selected = flag;
}

-(BOOL)isHighlighted
{
	return selected;
}

- (NSSize)cellSizeForBounds:(NSRect)aRect {
    // Make our cells a bit higher than normal to give some additional space for the icon to fit.
    NSSize theSize = [super cellSizeForBounds:aRect];
    theSize.height += ICON_SIZE + ICON_INSET_VERT * 2.0 + 10;
    return theSize;
}

- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {
	NSSize	imageSize = NSMakeSize(128, 128); //[iconImage size];
	NSRect	imageFrame, highlightRect, textFrame;
	
	// First, let's draw a frame around the cell
	
	// Divide the cell into 2 parts, the image part (on the left) and the text part.
	NSDivideRect(cellFrame, &imageFrame, &textFrame, 
				 128 + 4.0 * 2.0, 
				 NSMinYEdge);
	imageFrame.origin.x += (cellFrame.size.width - imageSize.width) / 2.0;
	imageFrame.size = imageSize;
	
	imageFrame.origin.y += 4.0;
	
	// Adjust the image frame top account for the fact that we may or may not be in a flipped control view, since when compositing
	// the online documentation states: "The image will have the orientation of the base coordinate system, regardless of the destination coordinates".
	if ([controlView isFlipped]) 
		imageFrame.origin.y += imageSize.width; //ceil((textFrame.size.height + imageFrame.size.height) / 2);
//	else 
//		; // Something is wrong. We're supposed to only render in an NSMatrix...
	
	// Depending on the current state, set the color we will highlight with.
	
	// Highlighting is f'ing bork. Ask if we're the selected cell instead.
	if ([(NSMatrix*)controlView selectedCell] == self) {
		// use highlightColorInView instead of [NSColor selectedControlColor] since NSBrowserCell slightly dims all cells except those in the right most column.
		// The return value from highlightColorInView will return the appropriate one for you. 
		//			[[NSColor s] set];
		[[self highlightColorInView: controlView] set];
	} else {
		[[NSColor controlBackgroundColor] set];
	}
	
	// Draw the highligh, bu only the portion that won't be caught by the call to [super drawInteriorWithFrame:...] below.  No need to draw parts 2 times!
	NSRectFill(cellFrame);

	NSFrameRect(cellFrame);
	
	// Blit the image.
	if(iconImage)
		[iconImage compositeToPoint:imageFrame.origin operation:NSCompositeSourceOver];
	else
	{
		// Draw an empty frame...
		[[NSColor blackColor] set];
		imageFrame.origin.y -= imageSize.width;
		NSFrameRect(imageFrame);
	}
	
	// Have NSBrowser kindly draw the text part, since it knows how to do that for us, no need to re-invent what it knows how to do.
//	NSFrameRect(textFrame);
	int newWidth = textFrame.size.width - 30;
//	NSLog(@"Truncating to length of %d", newWidth);
	[self setStringValue:[[[[[NSAttributedString alloc] 
		initWithString:title] autorelease] truncateForWidth:newWidth] string]];
	[self setAlignment:NSCenterTextAlignment];
//	NSLog(@"Displaying %@", [self stringValue]);
	[super drawInteriorWithFrame:textFrame inView:controlView];
	
	// Now we set the path back
	[self setStringValue:title];
}


@end
