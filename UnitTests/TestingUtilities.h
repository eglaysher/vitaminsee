//
//  TestingUtilities.h
//  VitaminSEE
//
//  Created by Elliot on 7/8/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NSString* getProjectDir();
NSString* getBuildDir();

NSString* buildTestingDirectory();
void destroyTestingDirectory(NSString* directory);
