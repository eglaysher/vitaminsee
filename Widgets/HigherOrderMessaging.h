//
//  HigherOrderMessaging.h
//  VitaminSEE
//
//  Created by Elliot on 12/31/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray(HigherOrderMessaging)
- (id)do;
- (id)collect;
- (id)select;
- (id)reject;
@end