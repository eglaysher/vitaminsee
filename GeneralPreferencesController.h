//
//  GeneralPreferencesController.h
//  CQView
//
//  Created by Elliot on 2/24/05.
//  Copyright 2005 Elliot Glaysher. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "SS_PreferencePaneProtocol.h"

@interface GeneralPreferencesController : NSObject <SS_PreferencePaneProtocol>
{
	IBOutlet NSView* prefView;
}

-(IBAction)changeDefaultDirectory:(id)sender;
-(IBAction)showHelp:(id)sender;

@end
