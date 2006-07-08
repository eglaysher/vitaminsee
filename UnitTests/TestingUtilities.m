//
//  TestingUtilities.m
//  VitaminSEE
//
//  Created by Elliot on 7/8/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "TestingUtilities.h"

/** Return the PROJECT_DIR environment variable, which should be set by XCode.
 * These tests are designed to be run from within XCode through SemTest.
 */
NSString* getProjectDir()
{
	char* fileCS = getenv("PROJECT_DIR");
	if(fileCS == NULL)
		[NSException raise:NSInternalInconsistencyException
					format:@"Environment is missing the PROJECT_DIR env var."];
	else
		return [NSString stringWithCString:fileCS];	
}

/** Return the build directory
 *
 */
NSString* getBuildDir()
{
	return [getProjectDir() stringByAppendingPathComponent:@"build"];
}

/** Helper function that builds a simple directory structure:
* [Root folder] (returned)
*  - A.jpg
*  - B_Folder
*    - dup.jpg
*  - C.jpg
*
*/
NSString* buildTestingDirectory() 
{	
	NSString* projectDir = getProjectDir();
	NSString* parent = getBuildDir();
	NSString* root = [parent stringByAppendingPathComponent:@"testing"];
	NSFileManager* fm = [NSFileManager defaultManager];
	
	if(![fm createDirectoryAtPath:root attributes:nil])
		[NSException raise:NSGenericException 
					format:@"Couldn't create testing directory"];
	
	// Get our image file to copy
	NSString* imgFile = [projectDir
		stringByAppendingPathComponent:@"UnitTests/Images/test1.png"];
	if(![fm fileExistsAtPath:imgFile])
		[NSException raise:NSInternalInconsistencyException
					format:@"Missing source file"];
	
	// Now copy that image file twice into strawman directory structure as A.jpg
	// and C.jpg
	NSString* ajpg = [root stringByAppendingPathComponent:@"A.jpg"];
	if(![fm copyPath:imgFile toPath:ajpg handler:nil])
		[NSException raise:NSInternalInconsistencyException
					format:@"Couldn't create A.jpg"];
	NSString* cjpg = [root stringByAppendingPathComponent:@"C.jpg"];
	if(![fm copyPath:imgFile toPath:cjpg handler:nil])
		[NSException raise:NSInternalInconsistencyException
					format:@"Couldn't create C.jpg"];
	
	// Now we create B_Folder
	NSString* bfolder = [root stringByAppendingPathComponent:@"B_Folder"];
	if(![fm createDirectoryAtPath:bfolder attributes:nil])
		[NSException raise:NSGenericException
					format:@"Couldn't create B_Folder"];
	
	// Make a final copy of the image in B_Folder
	NSString* bjpg = [bfolder stringByAppendingPathComponent:@"B.jpg"];
	if(![fm copyPath:imgFile toPath:bjpg handler:nil])
		[NSException raise:NSInternalInconsistencyException
					format:@"Couldn't create B.jpg"];	
	
	return root;
}

/** Helper function that recursivly deletes the directory structure built in
* buildTestingDirectory()
*/
void destroyTestingDirectory(NSString* directory) 
{
	NSFileManager* fm = [NSFileManager defaultManager];
	[fm removeFileAtPath:directory handler:nil];
}