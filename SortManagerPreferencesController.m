//
//  SortManagerPreferencesController.m
//  CQView
//
//  Created by Elliot on 2/22/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "SortManagerPreferencesController.h"


@implementation SortManagerPreferencesController

+(NSArray*)preferencePanes
{
	return [NSArray arrayWithObjects:[[[SortManagerPreferencesController alloc] init] autorelease], nil];
}

- (NSView *)paneView
{
    BOOL loaded = YES;
    
    if (!prefView) {
        loaded = [NSBundle loadNibNamed:@"SortManagerPreferences" owner:self];
    }
    
    if (loaded) {
        return prefView;
    }
    
    return nil;
}

- (NSString *)paneName
{
    return @"Sort Manager";
}

- (NSImage *)paneIcon
{
    return [[[NSImage alloc] initWithContentsOfFile:
        [[NSBundle bundleForClass:[self class]] pathForImageResource:@"General_Prefs"]
        ] autorelease];
}

- (NSString *)paneToolTip
{
    return @"Sort Manager Preferences";
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
