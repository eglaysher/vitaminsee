//
//  GeneralPreferencesController.m
//  CQView
//
//  Created by Elliot on 2/24/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "GeneralPreferencesController.h"


@implementation GeneralPreferencesController

-(IBAction)changeDefaultDirectory:(id)sender
{
	// Open a dialog modally. It's what iTunes does in the Advanced part of
	// preferences, which is what I'm trying to copy...
	int result;
    NSOpenPanel *oPanel = [NSOpenPanel openPanel];
	[oPanel setCanChooseDirectories:YES];
	[oPanel setCanChooseFiles:NO];
	[oPanel setAllowsMultipleSelection:NO];
	
	NSString* currentDirectory = [[NSUserDefaults standardUserDefaults]
		objectForKey:@"DefaultStartupPath"];
	
    result = [oPanel runModalForDirectory:currentDirectory
									 file:nil types:nil];
	
    if (result == NSOKButton) {
        NSArray *filesToOpen = [oPanel filenames];

		// count should equal 1, but let's loop just to be safe.
        int i, count = [filesToOpen count];
        for (i=0; i<count; i++) {
			[[NSUserDefaults standardUserDefaults] setObject:[filesToOpen objectAtIndex:i]
													  forKey:@"DefaultStartupPath"];
        }
    }
}

// GENERAL_PREFERENCES_ANCHOR
-(IBAction)showHelp:(id)sender
{
	[[NSHelpManager sharedHelpManager] openHelpAnchor:@"GENERAL_PREFERENCES_ANCHOR"
											   inBook:@"VitaminSEE Help"];
}

/////////////////////////////////////////// Protocol: SS_PreferencePaneProtocol

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
