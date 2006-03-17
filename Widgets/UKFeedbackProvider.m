//
//  UKFeedbackProvider.m
//  NiftyFeatures
//
//  Created by Uli Kusterer on Mon Nov 24 2003.
//  Copyright (c) 2003 M. Uli Kusterer. All rights reserved.
//

#import "UKFeedbackProvider.h"
#import <Message/NSMailDelivery.h>


@implementation UKFeedbackProvider


-(void) dealloc
{
	// Release all top-level objects from our NIB:
	[feedbackWindow release];
}

-(IBAction) sendFeedback: (id)sender
{
	[self orderFrontFeedbackWindow: sender];
}

-(IBAction) orderFrontFeedbackWindow: (id)sender
{
	if( !feedbackWindow )
		[NSBundle loadNibNamed: @"UKFeedbackProvider" owner: self];
	[feedbackWindow makeKeyAndOrderFront: sender];
}


-(IBAction) sendFeedbackButtonAction: (id)sender
{
	NSString*		msgText = [messageText string];
	NSString*		msgSubjPre = NSLocalizedString(@"FEEDBACK_SUBJECT_PREFIX", @"Prefix to use in front of subject so you can filter by it.");
	NSString*		msgSubj = [msgSubjPre stringByAppendingString: [subjectField stringValue]];
	NSString*		msgDest = NSLocalizedString(@"FEEDBACK_EMAIL", @"E-Mail address user's feedack should be sent to.");
	
	if( ![NSMailDelivery deliverMessage: msgText subject: msgSubj to: msgDest] )
	{
		NSBeginAlertSheet( NSLocalizedString(@"Couldn't send message", @"FEEDBACK_ERROR_TITLE"),
							NSLocalizedString(@"OK",@"FEEDBACK_ERRORR_BUTTON"), nil, nil,
							feedbackWindow, self, @selector(errorSheetDidEnd:returnCode:contextInfo:), 0, nil,
							NSLocalizedString(@"An error occurred while trying to send off your bug report, try using your e-mail client instead.", @"FEEDBACK_ERROR_MESSAGE"));
	}
	else
		[self closeFeedbackWindow: sender];
}


-(void) errorSheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
	
}


-(IBAction) closeFeedbackWindow: (id)sender
{
	[messageText setString: @""];
	[subjectField selectItemAtIndex: 0];
	[feedbackWindow orderOut: sender];
}


-(IBAction) openURL: (id)sender
{
	// This URL may be a "mailto:user@domain.net?subject=Feedback%20about%20NiftyFeatures" URL as well:
	[[NSWorkspace sharedWorkspace] openURL: [NSURL URLWithString: NSLocalizedString(@"FEEDBACK_URL", @"URL where the user can provide feedback.")]];
}


@end
