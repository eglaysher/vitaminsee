/////////////////////////////////////////////////////////////////////////
// File:          $Name$
// Module:        Utility functions
// Part of:       VitaminSEE
//
// Revision:      $Revision$
// Last edited:   $Date$
// Author:        $Author$
// Copyright:     (c) 2005 Elliot Glaysher
// Created:       2/6/05
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

#define min(a,b) (((a)<(b))?(a):(b))
struct DS {
	int width;
	int height;
};

NSImageRep* loadImage(NSString* path);
struct DS buildImageSize(int boxWidth, int boxHeight, int imageWidth, int imageHeight,
					  BOOL canScaleProportionally, float ratioToScale,
					  BOOL*canGetAwayWithQuickRender, float* ratioUsed);
float buildRatio(int first, int second);
BOOL imageRepIsAnimated(NSImageRep* rep);
NSImage* buildImageFromNormalFile(NSString* path, NSSize size);