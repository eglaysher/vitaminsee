//
//  FileOperations.h
//  CQView
//
//  Created by Elliot on 2/13/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "CQViewController.h"

@interface CQViewController (FileOperations)
-(int)deleteFile:(NSString*)file;
-(int)moveFile:(NSString*)file to:(NSString*)destination;
-(int)copyFile:(NSString*)file to:(NSString*)destination;
@end
