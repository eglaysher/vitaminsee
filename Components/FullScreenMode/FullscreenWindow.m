/////////////////////////////////////////////////////////////////////////
// File:          $URL$
// Module:        NSWindow subclass for the fullscreen "window"
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


#import "FullscreenWindow.h"

@implementation FullscreenWindow

-(id)initWithContentRect:(NSRect)contentRect
			   styleMask:(unsigned int)aStyle
				 backing:(NSBackingStoreType)bufferingType
				   defer:(BOOL)flag
{
	self = [super initWithContentRect:contentRect 
							styleMask:NSBorderlessWindowMask 
							  backing:NSBackingStoreBuffered 
								defer:YES];	
	return self;
}

// ---------------------------------------------------------------------------

-(BOOL)canBecomeKeyWindow
{
	return YES;
}

// ---------------------------------------------------------------------------

-(BOOL)canBecomeMainWindow
{
	return YES;
}

@end
