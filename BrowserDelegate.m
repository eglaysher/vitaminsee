//
//  BrowserDelegate.m
//  CQView
//
//  Created by Elliot on 1/27/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "BrowserDelegate.h"

#import "FSNodeInfo.h"

@implementation CQViewController (BrowserDelegate)

// ============================================================================
//                           BROWSER DELEGATION METHODS
// ============================================================================
- (id)browser:(NSBrowser*)browser numberOfRowsInColumn:(int)column
{
    NSString   *fsNodePath = nil;
    FSNodeInfo *fsNodeInfo = nil;
    
    // Get the absolute path represented by the browser selection, and create a fsnode for the path.
    // Since column represents the column being (lazily) loaded fsNodePath is the path for the last selected cell.
    fsNodePath = [self fsPathToColumn:column];
    fsNodeInfo = [FSNodeInfo nodeWithParent:nil atRelativePath:fsNodePath];
    
    return [[fsNodeInfo visibleSubNodes] count];
}

- (void)browser:(NSBrowser *)sender willDisplayCell:(id)cell atRow:(int)row column:(int)column {
    NSString   *containingDirPath = nil;
    FSNodeInfo *containingDirNode = nil;
    FSNodeInfo *displayedCellNode = nil;
    NSArray    *directoryContents = nil;
    
    // Get the absolute path represented by the browser selection, and create a fsnode for the path.
    // Since (row,column) represents the cell being displayed, containingDirPath is the path to it's containing directory.
    containingDirPath = [self fsPathToColumn:column];
    containingDirNode = [FSNodeInfo nodeWithParent:nil atRelativePath:containingDirPath];
    
    // Ask the parent for a list of visible nodes so we can get at a FSNodeInfo for the cell being displayed.
    // Then give the FSNodeInfo to the cell so it can determine how to display itself.
    directoryContents = [containingDirNode visibleSubNodes];
    displayedCellNode = [directoryContents objectAtIndex: row];
    
    [cell setAttributedStringValueFromFSNodeInfo: displayedCellNode];
}

// ============================================================================
//                           INTERNAL HELPER METHODS
// ============================================================================
- (NSString*)fsPathToColumn:(int)column {
    NSString *path = nil;
    if(column==0)
		path = [NSString stringWithFormat:@"/"];
    else 
		path = [browser pathToColumn:column];
    return path;
}


@end
