//
//  KeywordManagerPreferences.h
//  CQView
//
//  Created by Elliot on 2/27/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "SS_PreferencePaneProtocol.h"
#import "KeywordNode.h"

@interface KeywordManagerPreferences : NSObject <SS_PreferencePaneProtocol>
{
	IBOutlet NSView* prefView;
	IBOutlet NSOutlineView* outlineView;
	KeywordNode* keywordRoot;
}

-(IBAction)showHelp:(id)sender;
-(IBAction)addKeyword:(id)sender;
-(IBAction)remove:(id)sender;
-(void)saveKeywordsToUserDefaults;

@end
