#import "MyImageView.h"

@implementation MyImageView

- (void)mouseDown:(NSEvent *)theEvent
{
    startPt = [theEvent locationInWindow];
    startOrigin = [(NSClipView*)[self superview] documentVisibleRect].origin;

    NSCursor *grabCursor = [[NSCursor alloc] initWithImage:[NSImage imageNamed:@"hand_closed"] hotSpot:NSMakePoint(8, 8)];
    [(NSScrollView*)[self superview] setDocumentCursor:grabCursor];
    [grabCursor release];
}

- (void)mouseDragged:(NSEvent *)theEvent
{
    [self scrollPoint:
        NSMakePoint(startOrigin.x - ([theEvent locationInWindow].x - startPt.x),
                    startOrigin.y - ([theEvent locationInWindow].y - startPt.y))];
}

- (void)mouseUp:(NSEvent *)theEvent
{
    NSCursor *handCursor = [[NSCursor alloc] initWithImage:[NSImage imageNamed:@"hand_open"] hotSpot:NSMakePoint(8, 8)];
    [(NSScrollView*)[self superview] setDocumentCursor:handCursor];
    [handCursor release];
}

@end
