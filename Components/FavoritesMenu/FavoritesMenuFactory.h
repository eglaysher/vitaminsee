//
//  FavoritesMenuFactory.h
//  VitaminSEE
//
//  Created by Elliot Glaysher on 10/23/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface FavoritesMenuFactory : NSObject {
}

-(id)buildMenuDelegate;
-(id)buildToolbarItemWithIdentifier:(NSString*)itemIdent;

-(void)addDirectoryToFavorites:(NSString*)directory;

@end
