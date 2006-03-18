//
//  UKFeedbackProvider.m
//  NiftyFeatures
//
//  Created by Uli Kusterer on Mon Nov 24 2003.
//  Copyright (c) 2003 M. Uli Kusterer. All rights reserved.
//

#import "UKFeedbackProvider.h"
#import <Message/NSMailDelivery.h>

#import <Foundation/Foundation.h>


@implementation UKFeedbackProvider


-(void) dealloc
{
	// Release all top-level objects from our NIB:
	[feedbackWindow release];
	[super dealloc];
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


// WARNING: BIG CHANGE!!!! (by ERG)
// In the original code, UK used NSMailDelivery, which does nothing but
// throw exceptions for me. I've thus replaced it with an expansion of the
// code in UKCrashReporter, which submits data to a webform using an
// HTTP POST command instead of using email. The script on the web server
// will then act as a remailer and send it to me, or later on, add it to 
// a bug tracking database.
-(IBAction) sendFeedbackButtonAction: (id)sender
{
	Class			NSMutableURLRequestClass = NSClassFromString( @"NSMutableURLRequest" );
	Class			NSURLConnectionClass = NSClassFromString( @"NSURLConnection" );
	if( NSMutableURLRequestClass == Nil || NSURLConnectionClass == Nil )
		return;
	
	NSData*		msgText = [[messageText string] dataUsingEncoding: NSUTF8StringEncoding];
	NSData*     msgSubj = [[subjectField stringValue] dataUsingEncoding: NSUTF8StringEncoding];
	
	// Prepare a request:
	NSMutableURLRequest *postRequest = [NSMutableURLRequestClass requestWithURL: [NSURL URLWithString: NSLocalizedString( @"FEEDBACK_REPORT_CGI_URL", @"" )]];
	NSString            *boundary = @"0xKhTmLbOuNdArY";
	NSURLResponse       *response = nil;
	NSError             *error = nil;
	NSString            *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
	NSString			*agent = @"UKCrashReporter";
	
	// Add form trappings to crashReport:
	NSData*			header = [[NSString stringWithFormat:@"--%@\r\nContent-Disposition: form-data; name=\"feedback\"\r\n\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding];
	NSMutableData*	formData = [[header mutableCopy] autorelease];
	[formData appendData:msgText];
	[formData appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];

	// Add subject line:
	[formData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"subject\"\r\n\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[formData appendData:msgSubj];
	[formData appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	
	// setting the headers:
	[postRequest setHTTPMethod: @"POST"];
	[postRequest setValue: contentType forHTTPHeaderField: @"Content-Type"];
	[postRequest setValue: agent forHTTPHeaderField: @"User-Agent"];
	[postRequest setHTTPBody: formData];
	
	(NSData*) [NSURLConnectionClass sendSynchronousRequest: postRequest returningResponse: &response error: &error];

	// I'd love to do some sort of error checking on the above, but I can't.
	// How do you get an HTTP return code from a generalized URL abstraction?
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
