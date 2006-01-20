//
//  FileOperations.h
//  VitaminSEE
//
//  Created by Elliot on 1/16/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class EGPath;

@interface FileOperations : NSObject {

}

-(int)deleteFile:(EGPath*)path;
-(int)moveFile:(EGPath*)inFile to:(EGPath*)inDestination;
-(int)copyFile:(EGPath*)file to:(EGPath*)destination;

@end
