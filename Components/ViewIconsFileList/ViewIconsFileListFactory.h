//
//  ViewIconsFileViewFactory.h
//  Prototype
//
//  Created by Elliot Glaysher on 8/28/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "FileList.h"

@interface ViewIconsFileListFactory : NSObject <FileListFactory> {
}
-(id<FileList>)build;
@end
