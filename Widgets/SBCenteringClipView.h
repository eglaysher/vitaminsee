//
//  SBCenteringClipView.h
//  CQView
//
//  Created by Elliot on 2/3/05.
//  Copyright 2005 Elliot Glaysher. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface SBCenteringClipView : NSClipView {
	IBOutlet id scrollView;
}
-(void)setScrollView:(id)inScrollView;
-(void)centerDocument;
@end
