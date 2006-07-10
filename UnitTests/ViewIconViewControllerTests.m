/////////////////////////////////////////////////////////////////////////
// File:          $URL$
// Module:        Unit tests for the the ViewIconViewController
// Part of:       VitaminSEE
//
// Revision:      $Revision$
// Last edited:   $Date$
// Author:        $Author$
// Copyright:     (c) 2005 Elliot Glaysher
// Created:       3/24/06
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


#import "ViewIconViewControllerTests.h"
#import "ComponentManager.h"
#import "ViewIconViewController.h"
#import "TestingUtilities.h"

#import "EGPath.h"

@implementation ViewIconViewControllerTests

-(void)testChangingToSpecificDirectory
{
	NSString* testingDirectory;
	
	@try
	{
		testingDirectory = buildTestingDirectory();
	
		// Build a ViewIconViewController
		ViewIconViewController* controller =
			[[ComponentManager getFileListPluginNamed:@"ViewAsIcons"] build];
		[controller setDelegate:self];
		
		// Make sure we can set the directory in this view
		STAssertTrue([controller canSetDirectory], 
					 @"Wrong value for -canSetDirectory");
		
		// Set the current directory to the testing directory
		EGPath* egTestingDirectory = [EGPath pathWithPath:testingDirectory];
		STAssertTrue([controller setDirectory:egTestingDirectory],
					 @"Couldn't open directory %@", egTestingDirectory);

		// OK, so we should be on the first file of three.
		STAssertEqualObjects([currentFile fileName], @"A.jpg",
					   @"Not set to the first file!");
		STAssertFalse([controller canGoPreviousFile],
					  @"Can go previous file");
		STAssertTrue([controller canGoNextFile],
					 @"Can't go next file");
		STAssertFalse([controller canGoBack],
					  @"Says we can go back, though no history");
		STAssertFalse([controller canGoForward],
					  @"Says we can go forward, though no history");

		// Select the directory
		EGPath* bfolderLocation = [egTestingDirectory pathByAppendingPathComponent:@"B_Folder"];
		STAssertTrue([controller focusOnFile:bfolderLocation],
					 @"Couldn't focus on B_Folder");
		STAssertTrue([controller canGoPreviousFile],
					  @"Can't go previous file");
		STAssertTrue([controller canGoNextFile],
					 @"Can't go next file");
		STAssertEqualObjects(currentFile, bfolderLocation,
							 @"currentFile is not what we expect");
		
		// Open the directory
		STAssertTrue([controller setDirectory:bfolderLocation],
					 @"Couldn't open directory %@", bfolderLocation);
		STAssertEqualObjects([controller directory], bfolderLocation,
							 @"Did not set directory to %@; location is %@ instead", 
							 bfolderLocation, currentFile);
		STAssertEqualObjects([currentFile fileName], @"B.jpg",
							 @"Wrong file name after directory switch!");
		STAssertTrue([controller canGoBack],
					 @"Can't go back");
		STAssertFalse([controller canGoForward],
					  @"Can go forward");
		STAssertFalse([controller canGoNextFile],
					  @"Can go next file in directory with 1 file.");
		STAssertFalse([controller canGoPreviousFile],
					  @"Can go previous file in a directory with 1 file.");
		
		// Now try to go back
		[controller goBack];
		STAssertEqualObjects([controller directory], egTestingDirectory,
							 @"Wrong directory on goBack.");
		STAssertEqualObjects([currentFile fileName], @"B_Folder",
							 @"Doesn't highlight B_Folder on goBack.");
		STAssertTrue([controller canGoForward],
					 @"Can't goForward after goBack");
		STAssertFalse([controller canGoBack],
					  @"Can goBack after another goBack and no history.");
	}
	@finally
	{	
		// Clean up our temporary Directory;
		destroyTestingDirectory(testingDirectory);		
	}
}

//-----------------------------------------------------------------------------
//---------------------------------------------------------- DELEGATE: FileList
//-----------------------------------------------------------------------------

-(void)setDisplayedFileTo:(EGPath*)file
{
	[file retain];
	[currentFile release];
	currentFile = file;
}

//-----------------------------------------------------------------------------

-(EGPath*)currentFile
{
	return currentFile;
}

//-----------------------------------------------------------------------------

-(void)updateWindowTitle { }

@end
