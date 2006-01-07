/////////////////////////////////////////////////////////////////////////
// File:          $Name$
// Module:        All categories I've written or ripped off. Copyright in 
//                implementation file.
// Part of:       VitaminSEE
//
// Revision:      $Revision$
// Last edited:   $Date$
// Created:       3/23/05
//
/////////////////////////////////////////////////////////////////////////

#import <Cocoa/Cocoa.h>

// These additions to NSMUtableArray are my own:
@interface NSMutableArray (SortedMutableArray)
-(unsigned)lowerBoundToInsert:(id)object withSortSelector:(SEL)sortSelector;
-(void)insertObject:(id)anObject withSortSelector:(SEL)sortSelector;
-(unsigned)binarySearchFor:(id)object withSortSelector:(SEL)sortSelector;
-(void)removeObject:(id)object withSortSelector:(SEL)sortSelector;
@end

// This category is from the BSDed Growl Project, and was written by Karl Adam.
@interface NSWorkspace (GrowlAdditions)
-(NSImage*)iconForApplication:(NSString*)inName;
@end

// This category is from Karelia Software. Full liscence in source.
//@interface NSAttributedString (Truncation)
//-(NSAttributedString*)truncateForWidth:(float)inWidth;
//@end

@interface NSString (Truncation)
- (NSString *)truncateForWidth:(float) inWidth;
@end

// This category is also from Karelia Software.
@interface NSView (Set_and_get)
-(void)setSubview:(NSView *)inView;
-(id)subview;
@end

@interface NSWindow (TitleBarWidth)
- (float) titleBarHeight;
@end
