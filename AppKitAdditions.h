//
//  AppKitAdditions.h
//  VitaminSEE
//
//  Created by Elliot on 3/23/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

// This category is from the BSDed Growl Project, and was written by Karl Adam.
@interface NSWorkspace (GrowlAdditions)
- (NSImage *) iconForApplication:(NSString *) inName;
@end

// This category is from Karelia Software. Full liscence in source.
@interface NSAttributedString (Truncation)
-(NSAttributedString*)truncateForWidth:(float)inWidth;
@end

// This category is also from Karelia Software.
@interface NSView (Set_and_get)
- (void) setSubview:(NSView *)inView;
- (id) subview;
@end