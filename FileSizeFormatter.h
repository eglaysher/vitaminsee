//
//  FileSizeFormatter.h
//  CQView
//
//  Created by Elliot on 2/2/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface FileSizeFormatter : NSFormatter {
}

// The three things you need to override...
-(NSString*)stringForObjectValue:(id)obj;
//-(BOOL)getObjectValue:(id *)obj forString:(NSString *)string 
//	 errorDescription:(NSString **)error;
//-(NSAttributedString*)attributedStringForObjectValue:(id)anObject 
//							   withDefaultAttributes:(NSDictionary*)attributes;

@end
