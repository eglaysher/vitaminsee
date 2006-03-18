/////////////////////////////////////////////////////////////////////////
// File:          $URL$
// Module:        Main Controller Class
// Part of:       VitaminSEE
//
// ID:            $Id: ApplicationController.m 123 2005-04-18 00:21:02Z elliot $
// Revision:      $Revision$
// Last edited:   $Date$
// Author:        $Author$
// Copyright:     (c) 2005 Somebody Else
// Created:       2/3/05
//
/////////////////////////////////////////////////////////////////////////

#import <Cocoa/Cocoa.h>

@interface SBCenteringClipView : NSClipView {
	IBOutlet id scrollView;
}
-(void)setScrollView:(id)inScrollView;
-(void)centerDocument;
@end
