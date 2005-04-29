/////////////////////////////////////////////////////////////////////////
// File:          $Name$
// Module:        Popup buttons in NSToolbarItems. Copied from Adium who adapted
//                it from Colloquy. Isn't the GPL great?
// Part of:       VitaminSEE
//
// Revision:      $Revision$
// Last edited:   $Date$
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

@interface MVMenuButton : NSButton {
	NSImage				*bigImage;
	NSImage				*smallImage;
	NSToolbarItem 		*toolbarItem;
	NSBezierPath 		*arrowPath;
	
	BOOL				drawsArrow;
	NSControlSize 		controlSize;
}

- (void)setControlSize:(NSControlSize)inSize;
- (NSControlSize)controlSize;

- (void)setImage:(NSImage *)inImage;
- (NSImage *)image;
- (void)setSmallImage:(NSImage *)image;
- (NSImage *)smallImage;

- (void)setToolbarItem:(NSToolbarItem *)item;
- (NSToolbarItem *)toolbarItem;

- (void)setDrawsArrow:(BOOL)inDraw;
- (BOOL)drawsArrow;

@end
