/////////////////////////////////////////////////////////////////////////
// File:          $Name$
// Module:        Menu Delegate object that reads a list of applications that
//                can handle a certain file
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

#import "OpenWithMenuDelegate.h"


@implementation OpenWithMenuDelegate

//-(id)init
//{
//	return [super init];
//}

-(id)initWithPluginLayer:(PluginLayer*)pl
{
	if(self = [super init])
	{
		pluginLayer = [pl retain];
		fileTypeToArrayOfApplicationURLS = [[NSMutableDictionary alloc] init];
	}
	
	return self;
}

-(void)dealloc
{
	[super dealloc];
}
	
-(int)numberOfItemsInMenu:(NSMenu *)menu
{
//	if(!allApplications)
//	{
//		// Ask Launch Services for a list of all applications. We only need
//		// this once; we then cache this data and then use this list for all
//		// subsequent calls.
//		_LSCopyAllApplicationURLs(&allApplications);
//	}
//	
//	NSString* currentFile = [pluginLayer currentFile]
//	NSString* extensionOfCurrentFile = [currentFile pathExtension];
//	NSArray* listOfApplications = [fileTypeToArrayOfApplicationURLS 
//		objectForKey:extensionOfCurrentFile];
//	if(listOfApplications)
//		return [listOfApplications count];
//	else
//	{
//		// Go through the list of all Applications, ask Launch services if
//		// this application can handle the current file type, and then note it
//		// if it can
//		NSMutableArray* listOfApplications = [NSMutableArray array];
//		
//		NSEnumerator* e = [allApplications objectEnumerator];
//		NSURL* url;
//		Boolean accepted;
//		while(url = [e nextObject])
//		{
//			LSCanURLAcceptURL(currentFile, url, kLSRolesAll, kLSAcceptDefault, &accepted);
//			if(accepted)
//				[listOfApplications addObject:url];
//		}
//		
//		NSLog(@"Can open %@: %@", extensionOfCurrentFile, listOfApplications);
//		
//		[fileTypeToArrayOfApplicationURLS setObject:listOfApplications forKey:extensionOfCurrentFile];
//		return [fileTypeToArrayOfApplicationPaths count];
//	}
}

	
@end
