//
//  GeneralPreferencesController.m
//  CQView
//
//  Created by Elliot on 2/24/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "GeneralPreferencesController.h"


@implementation GeneralPreferencesController
/////////////////////////////////////////// Protocol: SS_PreferencePaneProtocol

// GENERAL_PREFERENCES_ANCHOR
-(IBAction)showHelp:(id)sender
{
	[[NSHelpManager sharedHelpManager] openHelpAnchor:@"GENERAL_PREFERENCES_ANCHOR"
											   inBook:@"VitaminSEE Help"];
}

+(NSArray*)preferencePanes
{
	return [NSArray arrayWithObjects:[[[GeneralPreferencesController alloc]
		init] autorelease], nil];
}

- (NSView *)paneView
{
    BOOL loaded = YES;
    
    if (!prefView)
        loaded = [NSBundle loadNibNamed:@"GeneralPreferences" owner:self];
    
    if (loaded)
        return prefView;
    
    return nil;
}

- (NSString *)paneName
{
    return @"General";
}

- (NSImage *)paneIcon
{
	// Fix this...
    return [[[NSImage alloc] initWithContentsOfFile:
        [[NSBundle bundleForClass:[self class]] pathForImageResource:@"General_Prefs"]
        ] autorelease];
}

- (NSString *)paneToolTip
{
    return @"General Preferences";
}

- (BOOL)allowsHorizontalResizing
{
    return NO;
}

- (BOOL)allowsVerticalResizing
{
    return NO;
}

@end
