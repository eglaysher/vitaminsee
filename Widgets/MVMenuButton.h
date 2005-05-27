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
