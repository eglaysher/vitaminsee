//
//  HigherOrderMessaging.m
//  VitaminSEE
//
//  Created by Elliot on 12/31/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "HigherOrderMessaging.h"
#import "BSTrampoline.h"

@implementation NSArray(HigherOrderMessaging)

- (id)do {
    return [[[BSTrampoline alloc] initWithEnumerator:[self objectEnumerator]
												mode:kDoMode] autorelease];
}

- (id)collect {
    return [[[BSTrampoline alloc] initWithEnumerator:[self objectEnumerator]
												mode:kCollectMode] autorelease];
}

- (id)select {
    return [[[BSTrampoline alloc] initWithEnumerator:[self objectEnumerator] 
												mode:kSelectMode] autorelease];
}

- (id)reject {
    return [[[BSTrampoline alloc] initWithEnumerator:[self objectEnumerator] 
												mode:kRejectMode] autorelease];
}

@end