//
//  ViewIconViewControllerTests.h
//  VitaminSEE
//
//  Created by Elliot on 6/24/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>

@class EGPath;
@protocol FileListDelegate;

@interface ViewIconViewControllerTests : SenTestCase <FileListDelegate> {
	EGPath* currentFile;
}

@end
