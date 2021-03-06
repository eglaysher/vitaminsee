/////////////////////////////////////////////////////////////////////////
// File:          $URL$
// Module:        Utility functions
// Part of:       VitaminSEE
//
// ID:            $Id: ApplicationController.m 123 2005-04-18 00:21:02Z elliot $
// Revision:      $Revision$
// Last edited:   $Date$
// Author:        $Author$
// Copyright:     (c) 2005 Elliot Glaysher
// Created:       9/18/05
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
////////////////////////////////////////////////////////////////////////


#import <Cocoa/Cocoa.h>

#ifdef __cplusplus
extern "C"
{
#endif        /* __cplusplus */

NSNumber* buildRatio(float first, float second);
BOOL imageRepIsAnimated(NSImageRep* rep);
BOOL floatEquals(float one, float two, float tolerance);
BOOL isInFavorites(NSString* path);

#ifdef __cplusplus
}
#endif        /* __cplusplus */
	