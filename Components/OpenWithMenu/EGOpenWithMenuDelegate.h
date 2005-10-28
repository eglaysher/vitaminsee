/////////////////////////////////////////////////////////////////////////
// File:          $Name$
// Module:        Menu Delegate object that reads the list of favorite locations
//                and displays them in a menu.
// Part of:       VitaminSEE
//
// Revision:      $Revision: 149 $
// Last edited:   $Date: 2005-04-29 14:32:49 -0400 (Fri, 29 Apr 2005) $
// Author:        $Author: elliot $
// Copyright:     (c) 2005 Elliot Glaysher
// Created:       5/14/2005
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


/*!
    @class		EGOpenWithMenuDelegate
    @abstract   A NSMenu delegate for displaying an "Open With…" menu.
    @discussion 
 
	Apple does not make it easy to write a clone of the Finder's "Open With..."
	menu. First of all, NSWorkspace gives you the option of either opening a 
	file with the default application, or with a programmer specified path to
	an application, but it doesn't give you a list of applications that can
	support a certain file type.
 
	This delegate class encapsulates all the logic needed to create an Open With
	menu, and will then call the delegate's openWithMenuDelegate:openCurrentFileWith:
	function
*/
@interface EGOpenWithMenuDelegate : NSObject {
	///
	NSMutableDictionary* fileTypeToArrayOfApplicationURLS;	
	
	/// Cached list of all the applications on the system. 
	NSArray* allApplications;
	
	id delegate;
}

-(id)delegate;
-(void)setDelegate:(id)inDelegate;

-(int)numberOfItemsInMenu:(NSMenu *)menu;

- (BOOL)menu:(NSMenu *)menu 
  updateItem:(NSMenuItem *)item 
	 atIndex:(int)index 
shouldCancel:(BOOL)shouldCancel;

//-(NSMenu*)buildCompatibleMenu;

@end


@interface NSObject (EGOpenWithMenuDelegateInformalInterface)

/*!
	@method		openWithMenuDelegate:openCurrentFileWith:
	@description
	When the user selects an application from the menu, this delegate function
	will be called with the path of the selected application.
*/
-(void)openWithMenuDelegate:(EGOpenWithMenuDelegate*)openWithMenu
		openCurrentFileWith:(NSString*)pathToApplication;

/*!
    @method     currentFilepathForOpenWithMenuDelegate
    @description
	EGOpenWithMenuDelegateInformalInterface will querry it's delegate right before
	it opens a menu for a filename. This filename is assumed to be the file that
	will be used when the user selects one of the menu items.
*/
-(NSString*)currentFilePathForOpenWithMenuDelegate;

/*!
    @method     openWithMenuDelegate:shouldShowItem:
    @discussion
	If the delegate defines this method, then each item is passed by this function
*/
-(BOOL)openWithMenuDelegate:(EGOpenWithMenuDelegate*)openWithMenu
			 shouldShowItem:(NSDictionary*)item;

@end