//
//  SortManagerPreferencesController.h
//  CQView
//
//  Created by Elliot on 2/22/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "SS_PreferencePaneProtocol.h"

@interface SortManagerPreferencesController : NSObject <SS_PreferencePaneProtocol> 
{
	IBOutlet NSView* prefView;
	IBOutlet NSArrayController* listOfDirectories;
}

-(IBAction)add:(id)sender;

@end
