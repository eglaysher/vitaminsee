//
//  AddIcon.h
//  AddIcon
//
//  Created by Elliot Glaysher on 6/3/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Automator/AMBundleAction.h>

@interface AddIcon : AMBundleAction 
{
}

- (id)runWithInput:(id)input fromAction:(AMAction *)anAction error:(NSDictionary **)errorInfo;

@end
