/////////////////////////////////////////////////////////////////////////
// File:          $URL$
// Module:        Menu Delegate object that reads a list of applications that
//                can handle a certain file
// Part of:       VitaminSEE
//
// Revision:      $Revision$
// Last edited:   $Date$
// Author:        $Author$
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

#import "EGOpenWithMenuDelegate.h"

#import <Carbon/Carbon.h>
#import <ApplicationServices/ApplicationServices.h>

// These helper functions do most of the heavy lifting in figuring out the list
// of menu items to display.
//static NSArray* getOpenWithMenuFor(NSString* file, NSArray* applicationURLs);
static NSArray* getListOfApplicationsThatCanOpenExtension(NSString* file, NSArray* array);
static BOOL applicationCanHandleFileType(NSURL* applicationURL, NSString* fileExtension);
static NSMutableArray* buildApplicationArray(NSArray* arrayOfURLs);
static void removeTrashedPathsFromArray(NSMutableArray* applicationArray);
static void removeDuplicateEntries(NSMutableArray* appilcationArray);
static void checkForDuplicateEntries(NSMutableArray* entriesToDoubleCheck, 
									 NSMutableArray* entriesToRemove);
static void buildDisplayName(NSMutableArray* appilcationArray);

// Use an unsupported funcction from apple
extern void _LSCopyAllApplicationURLs(NSArray**);

@interface EGOpenWithMenuDelegate (Private)
-(NSString*)getCurrentFile;
-(NSArray*)getOpenWithMenuFor:(NSString*)file urls:(NSArray*) applicationURLs;
@end

@implementation EGOpenWithMenuDelegate

-(id)init
{
	if(self = [super init])
	{
		fileTypeToArrayOfApplicationURLS = [[NSMutableDictionary alloc] init];
	}
	
	return self;
}

// ---------------------------------------------------------------------------

-(void)dealloc
{
	[super dealloc];
}

// ---------------------------------------------------------------------------

-(id)delegate
{
	return delegate;
}

// ---------------------------------------------------------------------------

-(void)setDelegate:(id)inDelegate
{
	delegate = inDelegate;
}

// ---------------------------------------------------------------------------

-(int)numberOfItemsInMenu:(NSMenu *)menu
{	
	if(!allApplications)
	{
		// Ask Launch Services for a list of all applications. We only need
		// this once; we then cache this data and then use this list for all
		// subsequent calls.
		_LSCopyAllApplicationURLs(&allApplications);
	}
	
	NSString* currentFile = [self getCurrentFile];
	
	// If the current file is a folder, then just ignore. We eat way too much
	// time on folders.
	BOOL isDir;
	if([[NSFileManager defaultManager] fileExistsAtPath:currentFile isDirectory:&isDir] && isDir)
		return 0;

	NSString* extensionOfCurrentFile = [currentFile pathExtension];
	NSArray* listOfApplications = [fileTypeToArrayOfApplicationURLS 
		objectForKey:extensionOfCurrentFile];
	if(listOfApplications)
		return [listOfApplications count];
	else if(currentFile == NULL)
		return 0;
	else
	{
		listOfApplications = [self getOpenWithMenuFor:currentFile urls:allApplications];		
		
		[fileTypeToArrayOfApplicationURLS setObject:listOfApplications forKey:extensionOfCurrentFile];
		return [listOfApplications count];
	}
}

// ---------------------------------------------------------------------------

-(BOOL)menu:(NSMenu *)menu updateItem:(NSMenuItem *)item atIndex:(int)index shouldCancel:(BOOL)shouldCancel
{
	NSString* currentFile = [self getCurrentFile];
	NSArray* currentFileType = [fileTypeToArrayOfApplicationURLS objectForKey:[currentFile pathExtension]];
	NSDictionary* currentApplication = [currentFileType objectAtIndex:index];
	
	[item setTitle:[currentApplication objectForKey:@"DisplayName"]];
	[item setTarget:self];
	[item setAction:@selector(menuItemSelected:)];
	[item setKeyEquivalent:@""];
	[item setRepresentedObject:currentApplication];	
	
	// Set the image
	NSString* pathString = [currentApplication objectForKey:@"Path"];
	NSImage* image = [[[[NSWorkspace sharedWorkspace] iconForFile:pathString] copy] autorelease];
	[image setScalesWhenResized:YES];
	[image setSize:NSMakeSize(16,16)];
	[item setImage:image];
	
//	NSLog(@"item ref count: %d", [item retainCount]);
	
	return YES;
}

// ---------------------------------------------------------------------------

-(void)menuItemSelected:(id)sender
{
	if([delegate respondsToSelector:@selector(openWithMenuDelegate:openCurrentFileWith:)])
	{
		[delegate openWithMenuDelegate:self openCurrentFileWith:[[sender representedObject] objectForKey:@"Path"]];
	}
	else
		[NSException raise:@"InvalidDelegate"
					format:@"Delegate %@ does not respond to required delegate method openWithMenuDelegate:openCurrentFileWith:",
				delegate];
}
	
@end

// ---------------------------------------------------------------------------

@implementation EGOpenWithMenuDelegate (Private)

-(NSString*)getCurrentFile
{
	NSString* currentFile = 0;
	if([delegate respondsToSelector:@selector(currentFilePathForOpenWithMenuDelegate)])
	{
		currentFile = [delegate currentFilePathForOpenWithMenuDelegate];
	}
	else
		[NSException raise:@"InvalidDelegate"
					format:@"Delegate %@ does not respond to required delegate method currentFilePathForOpenWithMenuDelegate",
				 delegate];

	return currentFile;
}

// ---------------------------------------------------------------------------

-(NSArray*)getOpenWithMenuFor:(NSString*)file urls:(NSArray*) applicationURLs
{
	NSArray* rawApplicationURLs = getListOfApplicationsThatCanOpenExtension(file, applicationURLs);
	NSMutableArray* applicationArray = buildApplicationArray(rawApplicationURLs);
	
	// Remove all items that are in a folder that has /.Trash/ in it; they won't work
	removeTrashedPathsFromArray(applicationArray);
	
	// Sort on the Name component, then the Version number.
	NSSortDescriptor* nameDescriptor = [[[NSSortDescriptor alloc] 
		initWithKey:@"Name" ascending:YES] autorelease];
	NSSortDescriptor* versionDescriptor = [[[NSSortDescriptor alloc] 
		initWithKey:@"Veresion" ascending:YES] autorelease];
	NSArray* descriptors = [NSArray arrayWithObjects:nameDescriptor, 
		versionDescriptor, nil];
	[applicationArray sortUsingDescriptors:descriptors];	
	
	// Remove entries with same 'Name' and 'Version'. Be biased towards copies
	// that have "Applications" in the path name. Otherwise pick first one.
	removeDuplicateEntries(applicationArray);
	
	// Generate display names.	
	buildDisplayName(applicationArray);
	
	// Now we need to pass these objects by the delegate if it exists.
	if([delegate respondsToSelector:@selector(openWithMenuDelegate:shouldShowItem:)])
	{
		NSMutableArray* applicationSource = applicationArray;
		applicationArray = [NSMutableArray array];
		
		NSEnumerator* e = [applicationSource objectEnumerator];
		NSDictionary* applicationDictionary;
		while(applicationDictionary = [e nextObject])
		{
			if([delegate openWithMenuDelegate:self shouldShowItem:applicationDictionary])
			{
				[applicationArray addObject:applicationDictionary];
			}
		}		
	}
	
	//	NSLog(@"paths: %@", applicationArray);
	
	// Pass back the dictionary
	return applicationArray;
}

@end

// -----------------------------------------------------------------------------

NSArray* getListOfApplicationsThatCanOpenExtension(NSString* file, NSArray* array)
{
	NSURL* fileURL = [NSURL fileURLWithPath:file];
	
	// Get list of Applications
//	NSArray *array;
//	_LSCopyAllApplicationURLs(&array);
	
	// Get a list of Applications that can handle fileExtension
	NSString* extensionOfCurrentFile = [file pathExtension];
	NSMutableArray* listOfApplications = [NSMutableArray array];
	
	NSEnumerator* e = [array objectEnumerator];
	NSURL* url;
	Boolean accepted;
	while(url = [e nextObject])
	{
		// Problem: This is what you can DRAG IN! Not what the program can open!
		// This function will return things that aren't in the Info.plist!
		// But it's fast and returns a superset of what we return, so use it and
		// do more checking
		LSCanURLAcceptURL((CFURLRef)fileURL, (CFURLRef)url, kLSRolesAll, kLSAcceptDefault, &accepted);
		if(accepted && applicationCanHandleFileType(url, extensionOfCurrentFile))
			[listOfApplications addObject:url];
	}
	
	return listOfApplications;
}

// ---------------------------------------------------------------------------

BOOL applicationCanHandleFileType(NSURL* applicationURL, NSString* fileExtension)
{
	// Okay, get
	NSString* upperExtension = [fileExtension uppercaseString];
	id infoPlist = [[NSBundle bundleWithPath:[applicationURL path]] infoDictionary];
	
	// Now see if this Application handles files
	NSArray* bundleDocumentTypes = [infoPlist objectForKey:@"CFBundleDocumentTypes"];
	if(bundleDocumentTypes)
	{
		NSEnumerator* e = [bundleDocumentTypes objectEnumerator];
		NSDictionary* typeDict;
		while(typeDict = [e nextObject])
		{
			NSArray* fileExtensionArray = [typeDict objectForKey:@"CFBundleTypeExtensions"];
			NSEnumerator* e = [fileExtensionArray objectEnumerator];
			NSString* extension;
			while(extension = [e nextObject])
				if([upperExtension isEqual:[extension uppercaseString]])
					return YES;
		}
	}
	
	return NO;
}

// ---------------------------------------------------------------------------

NSMutableArray* buildApplicationArray(NSArray* arrayOfURLs)
{
	// Make list into an array of dictionaries where each dictionary has data such as 
	NSEnumerator* e = [arrayOfURLs objectEnumerator];
	NSURL* url;
	NSMutableArray* processedURLs = [NSMutableArray array];
	while(url = [e nextObject])
	{
		NSMutableDictionary* infoDictionary = [NSMutableDictionary dictionary];
		NSString* path = [url path];
		[infoDictionary setObject:path forKey:@"Path"];
		
		// Get the normal and the localized plist files.
		id plist = [[NSBundle bundleWithPath:path] infoDictionary];
		id localizedPlist = [[NSBundle bundleWithPath:path] localizedInfoDictionary];
		
		// Get the version.
		NSString* version = [plist objectForKey:@"CFBundleVersion"];
		if(version)
			[infoDictionary setObject:version forKey:@"Version"];
		
		// Get the name. We first check the localized Plist, then the normal plist, then
		// fall back on the filesystem
		NSString* localizedName = [localizedPlist objectForKey:@"CFBundleName"];
		NSString* plistName = [plist objectForKey:@"CFBundleName"];
		if(localizedName)
			[infoDictionary setObject:localizedName forKey:@"Name"];
		else if(plistName)
			[infoDictionary setObject:plistName forKey:@"Name"];
		else
			[infoDictionary setObject:[path lastPathComponent] forKey:@"Name"];
		
		[processedURLs addObject:infoDictionary];		
	}
	
	return processedURLs;
}

// ---------------------------------------------------------------------------

void removeTrashedPathsFromArray(NSMutableArray* applicationArray)
{
	NSEnumerator* e = [applicationArray objectEnumerator];
	NSMutableDictionary* d;
	NSMutableArray* objectsToRemove = [NSMutableArray array];
	while(d = [e nextObject])
	{
		// If ".Trash" is in the file name, this object needs to be removed.
		if([[d objectForKey:@"Path"] rangeOfString:@".Trash"].location != NSNotFound)
			[objectsToRemove addObject:d];
	}
	
	[applicationArray removeObjectsInArray:objectsToRemove];
}

// ---------------------------------------------------------------------------

void removeDuplicateEntries(NSMutableArray* appilcationArray)
{
	NSMutableArray* entriesToRemove = [NSMutableArray array];
	NSEnumerator* e = [appilcationArray objectEnumerator];
	
	NSMutableDictionary* lastEntry = [e nextObject];
	if(!lastEntry)
		return;
	
	NSString* lastName = [lastEntry objectForKey:@"Name"];
	NSString* lastVersion = [lastEntry objectForKey:@"Version"];
	NSMutableDictionary* currentEntry;
	NSString* currentName;
	NSString* currentVersion;
	
	NSMutableArray* entriesToDoubleCheck = [NSMutableArray arrayWithObject:lastEntry];
	
	while(currentEntry = [e nextObject])
	{
		currentName = [currentEntry objectForKey:@"Name"];
		currentVersion = [currentEntry objectForKey:@"Version"];
		
		if([currentName isEqual:lastName] && [currentVersion isEqual:lastVersion])
		{
			[entriesToDoubleCheck addObject:currentEntry];
		}
		else
		{
			checkForDuplicateEntries(entriesToDoubleCheck, entriesToRemove);
			
			// Make a new list of things to double check with
			entriesToDoubleCheck = [NSMutableArray arrayWithObject:currentEntry];
		}
		
		lastName = currentName;
		lastVersion = currentVersion;
	}
	
	checkForDuplicateEntries(entriesToDoubleCheck, entriesToRemove);
	
	[appilcationArray removeObjectsInArray:entriesToRemove];
}

// ---------------------------------------------------------------------------

void checkForDuplicateEntries(NSMutableArray* entriesToDoubleCheck, 
							  NSMutableArray* entriesToRemove)
{
	if([entriesToDoubleCheck count] > 1)
	{
		//		// Go through the list and see if there are any entries in the applications
		//		if(applicationListHasAppInApplicationsFolder(entriesToDobuleCheck))
		//		{
		//			removeAllAppsNotInApplicationsFolder(entriesToDoubleCheck);
		//		}
		
		[entriesToDoubleCheck removeObjectAtIndex:0];
		[entriesToRemove addObjectsFromArray:entriesToDoubleCheck];
	}	
}

// ---------------------------------------------------------------------------

void buildDisplayName(NSMutableArray* appilcationArray)
{
	NSEnumerator* e = [appilcationArray objectEnumerator];
	NSMutableDictionary* lastEntry = [e nextObject];
	NSMutableDictionary* currentEntry;
	NSString* lastName = [lastEntry objectForKey:@"Name"];
	NSString* currentName;
	
	[lastEntry setObject:lastName forKey:@"DisplayName"];

	while(currentEntry = [e nextObject])
	{
		currentName = [currentEntry objectForKey:@"Name"];
		
		if([currentName caseInsensitiveCompare:lastName] == NSOrderedSame)
		{
			// Both this and the pervious entry need their names set (this may
			// double set the display name if their are three or more versions,
			// but that's a rare case and the small speed increase wouldn't be
			// worth it.
			NSString* lastVersion = [lastEntry objectForKey:@"Version"];
			[lastEntry setObject:[NSString stringWithFormat:@"%@ (%@)", lastName, lastVersion]
						  forKey:@"DisplayName"];
			
			NSString* currentVersion = [currentEntry objectForKey:@"Version"];
			[currentEntry setObject:[NSString stringWithFormat:@"%@ (%@)", currentName, currentVersion]
							 forKey:@"DisplayName"];
		}
		else
		{
			// Name is simple
			[currentEntry setObject:currentName forKey:@"DisplayName"];
		}
		
		lastEntry = currentEntry;
		lastName = currentName;
	}
}
