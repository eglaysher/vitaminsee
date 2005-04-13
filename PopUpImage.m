//
//  PopUpImage.m
//  MenuViewTest
//
//  Created by Matt Gemmell on Sun Jan 26 2003.
//  Use however you like.
//

#import "PopUpImage.h"

@implementation PopUpImage


/* ====================================================================================================	*/
/* 	Initializers											*/
/* ====================================================================================================	*/

- (id)initWithIcon:(NSImage *)theIcon popIcon:(NSImage*)thePopIcon
{
    /* Designated initializer */
    if (theIcon && thePopIcon) {
        /* Call our superclass' designated initializer */
        self = [super initWithFrame:NSMakeRect(0, 0, [theIcon size].width + [thePopIcon size].width, [theIcon size].height)];

        [self setLastIconFrameSize:[theIcon size]];
        
        [self setIcon:theIcon];
        [self setPopIcon:thePopIcon];
        
    } else if (theIcon) {
        /* If thePopImage is nil, just use theImage as our image */
        self = [super initWithFrame:NSMakeRect(0, 0, [theIcon size].width, [theIcon size].height)];;

        [self setLastIconFrameSize:[theIcon size]];
        
        [self setIcon:theIcon];
    }
    
    if (self) {
        /* These two lines give us proper highlighting with no border */
        [[self cell] setHighlightsBy:NSNoCellMask];
        [self setBordered:NO];
        
        /* Just show the image */
        [self setTitle:nil];
        [self setImagePosition:NSImageOnly];
        
        /* By default, enable receiving keyboard focus */
        [self setCanGetKeyboardFocus:YES];

        /* By default, enable showing the menu when the main icon is clicked (not just the popup-icon) */
        [self setShowsMenuWhenIconClicked:YES];
        
        /* By default, disable showing a checkmark beside the most recently selected item */
        [self setShowsSelectedItem:NO];

        /* By default, disable displaying the icon of the most recently selected item as our main image */
        [self setDisplaysIconOfSelectedItem:NO];

		[self setPo
    }
    
    return self;
}

- (id)initWithIcon:(NSImage *)theIcon
{
    return [self initWithIcon:theIcon popIcon:nil];
}

- (void) dealloc
{
    [menu release];
    
    [super dealloc];
}


/* ====================================================================================================	*/
/* 	Menu-related methods										*/
/* ====================================================================================================	*/

- (void)addItemWithTitle:(NSString *)title image:(NSImage *)img target:(id)trg action:(SEL)act
{
    /* First check to see if menu exists yet */
    if (!menu) {
        /* Make a default menu */
        [self setMenu:[[[NSMenu alloc] initWithTitle:@""] autorelease]];
    }
    
    /* Now create the new menu-item */
    if (!title) {
        title = @""; /* [NSMenuItem +initWithTitle:action:keyEquivalent:] won't accept a nil title */
    }
    NSMenuItem *newItem = [[NSMenuItem alloc] initWithTitle:title action:act keyEquivalent:@""];
    [newItem setImage:img];
    [newItem setTarget:trg];
    
    /* Add our new item to the menu */
    [[self menu] addItem:newItem];
    
    /* Set this new item to be selectedItem if there is no current selectedItem */
    if (![self selectedItem]) {
        [self setSelectedItem:newItem];
    }
    
    /* The menu retains the new item, so we can release it here */
    [newItem release];
}

- (void)addSeparator
{
    /* First check to see if menu exists yet */
    if (!menu) {
        /* Make a default menu */
        [self setMenu:[[[NSMenu alloc] initWithTitle:@""] autorelease]];
    }
    
    /* Now create the new separator */
    NSMenuItem *sepItem = [NSMenuItem separatorItem];
    [menu addItem:sepItem];
}

- (void)popUpMenuWithEvent:(NSEvent *)theEvent
{
    /* Make a new event identical to theEvent, but with a location at our frame's origin. */
    /* This ensures that the menu pops up in the proper place each time. */
	//
	// <Elliot> This assumption is completly wrong when this class gets put in
	// an NSToolbarItem.
    NSEvent *evt;
    
    if (!([theEvent type] & NSKeyDown)) {
        /* Mouse event */
		NSPoint newOrigin;
		// fixme: this needs better alginment.
		newOrigin.x = [[self superview] frame].origin.x + 5;
		newOrigin.y = [[self window] frame].size.height - 50;
        evt = [NSEvent mouseEventWithType:[theEvent type]
								 location:newOrigin
							modifierFlags:[theEvent modifierFlags]
								timestamp:[theEvent timestamp]
							 windowNumber:[theEvent windowNumber]
								  context:[theEvent context]
							  eventNumber:[theEvent eventNumber]
							   clickCount:[theEvent clickCount]
								 pressure:[theEvent pressure]];
    } else {
        /* Keyboard event */
        evt = [NSEvent keyEventWithType:[theEvent type]
                               location:[self frame].origin
                          modifierFlags:[theEvent modifierFlags]
                              timestamp:[theEvent timestamp]
                           windowNumber:[theEvent windowNumber]
                                context:[theEvent context]
                             characters:[theEvent characters]
            charactersIgnoringModifiers:[theEvent charactersIgnoringModifiers]
                              isARepeat:[theEvent isARepeat]
                                keyCode:[theEvent keyCode]];
    }
    
    /* Pop-up our menu in the appropriate place */
    [NSMenu popUpContextMenu:[self menu] withEvent:evt forView:self];
    
    /* Ensure that we always receive a mouseUp, so we can get rid of highlighting */
    [self mouseUp:evt];
}

- (NSString *)titleOfSelectedItem
{
    if ([self selectedItem]) {
        return [[self selectedItem] title];
    }

    return nil;
}

- (int)indexOfSelectedItem
{
    if ([self menu] && [self selectedItem]) {
        return [[self menu] indexOfItem:[self selectedItem]];
    }
    
    return -1;
}

/* ====================================================================================================	*/
/* 	Notification handlers									*/
/* ====================================================================================================	*/

- (void)menuDidSendAction:(id)notification
{
    /* Update selectedItem to be the menu-item which was just activated */
    NSMenuItem *chosenItem = [[notification userInfo] objectForKey:@"MenuItem"];
    if ([self selectedItem] != chosenItem) {
        [self setSelectedItem:chosenItem];
    }
}


/* ====================================================================================================	*/
/* 	Helper methods											*/
/* ====================================================================================================	*/

- (void)updateImage
{
    NSImage *theIcon = [self icon];
    NSImage *thePopIcon = [self popIcon];
    
    NSSize frameSize = [self frame].size;
    NSSize iconSize = [self lastIconFrameSize];
    
    NSRect iconDrawRect = NSMakeRect(0, 0, frameSize.width, frameSize.height);
    
    NSImage *itemImg = [[NSImage alloc] initWithSize:frameSize];
    
    if (theIcon && thePopIcon) {
        [theIcon setScalesWhenResized:YES];
        [thePopIcon setScalesWhenResized:YES];
        NSRect iconRect = NSMakeRect(0, 0, [theIcon size].width, [theIcon size].height);
        NSRect popRect = NSMakeRect(0, 0, [thePopIcon size].width, [thePopIcon size].height);

        NSSize popSize = NSMakeSize(frameSize.width - iconSize.width, [thePopIcon size].height);
        NSRect popDrawRect = NSMakeRect(iconSize.width, 0, popSize.width, popSize.height);
        
        /* Construct composite image using icon and popIcon */
        [itemImg lockFocus];
        [theIcon drawInRect:iconDrawRect fromRect:iconRect operation:NSCompositeSourceOver fraction:1.0];
        [thePopIcon drawInRect:popDrawRect fromRect:popRect operation:NSCompositeSourceOver fraction:1.0];
        [itemImg unlockFocus];
        
        [self setImage:[itemImg autorelease]];
        
    } else if (theIcon) {
        [theIcon setScalesWhenResized:YES];
        NSRect iconRect = NSMakeRect(0, 0, [theIcon size].width, [theIcon size].height);
        
        /* If popIcon is nil, just use icon as our image */
        [itemImg lockFocus];
        [theIcon drawInRect:iconDrawRect fromRect:iconRect operation:NSCompositeSourceOver fraction:1.0];
        [itemImg unlockFocus];
        
        [self setImage:[itemImg autorelease]];
    }
}

- (void)resizeToFit
{
    /* Resizes our frame to fit the native size of our icon (and popIcon if appropriate) */
    NSImage *theIcon = [self icon];
    NSImage *thePopIcon = [self popIcon];
    
    [self setLastIconFrameSize:[[self icon] size]];
    
    if (theIcon && thePopIcon) {
        [self setFrameSize:NSMakeSize([theIcon size].width + [thePopIcon size].width, [theIcon size].height)];
    } else if (theIcon) {
        [self setFrameSize:NSMakeSize([theIcon size].width, [theIcon size].height)];
    }
    [self updateImage];
}


/* ====================================================================================================	*/
/* 	Mouse/keyboard event handlers									*/
/* ====================================================================================================	*/

- (BOOL)acceptsFirstResponder
{
    return canGetKeyboardFocus;
}

- (void)mouseDown:(NSEvent *)theEvent
{
    if (![self isEnabled]) {
        return;
    }
    
    BOOL shouldShowMenu = YES;
    
    if (![self showsMenuWhenIconClicked]) {
        NSRect ourFrame = [self frame];
        shouldShowMenu = !(NSPointInRect([theEvent locationInWindow], NSMakeRect(ourFrame.origin.x, ourFrame.origin.y,
                                                                            [self lastIconFrameSize].width, ourFrame.size.height)));
    }

    if (!shouldShowMenu && [self displaysIconOfSelectedItem] && [self selectedItem]) {
        if ([[self selectedItem] action]) {
            [NSApp sendAction:[[self selectedItem] action] to:[[self selectedItem] target] from:[self selectedItem]];
            [self highlight:YES];
            return;
        }
    }
    
    if (!menu || !shouldShowMenu) {
        [super mouseDown:theEvent];
        return;
    }
    
    [self highlight:YES];
    
    /* Show our menu */
    [self popUpMenuWithEvent:theEvent];
}

- (void)mouseUp:(NSEvent *)theEvent
{
    [self highlight:NO];
    [super mouseUp:theEvent];
}

- (void)keyDown:(NSEvent *)theEvent
{
    if (![self isEnabled]) {
        return;
    }
    
    unichar theChar = [[theEvent characters] characterAtIndex:0];
    unichar space = [@" " characterAtIndex:0];
    
    if (!menu || (![self showsMenuWhenIconClicked] && theChar == space)) {
        if ([self displaysIconOfSelectedItem] && [self selectedItem]) {
            if ([[self selectedItem] action]) {
                [NSApp sendAction:[[self selectedItem] action] to:[[self selectedItem] target] from:[self selectedItem]];
                [self highlight:YES];
                return;
            }
        }
        [super keyDown:theEvent];
        return;
    }
    
    if (!(theChar == NSDownArrowFunctionKey ||
          theChar == NSUpArrowFunctionKey ||
          theChar == space
          )) {
        [super keyDown:theEvent];
        return;
    }
    
    [self highlight:YES];
    
    /* Show our menu */
    [self popUpMenuWithEvent:theEvent];
}

- (void)keyUp:(NSEvent *)theEvent
{
    [self highlight:NO];
    [super keyUp:theEvent];
}

- (NSMenu *)menuForEvent:(NSEvent *)theEvent
{
    /* Make us pop up our normal menu, in the proper place, when we receive a control-click or right-click */
    return nil;
}


/* ====================================================================================================	*/
/* 	Drawing methods											*/
/* ====================================================================================================	*/

- (void)drawRect:(NSRect)rect {
    /* Let our superclass (NSButton) do the drawing, so we get proper highlighting/disabling. */
    [super drawRect:rect];
}


/* ====================================================================================================	*/
/* 	Accessors											*/
/* ====================================================================================================	*/

- (NSString *)title
{
    if ([self selectedItem]) {
        return [[self selectedItem] title];
    }
    
    return nil;
}

- (NSImage *)icon
{
    return icon;
}

- (void)setIcon:(NSImage *)newIcon
{
    [newIcon retain];
    [icon release];
    icon = newIcon;
    
    [self updateImage];
}


- (NSImage *)popIcon
{
    return popIcon;
}

- (void)setPopIcon:(NSImage *)newPopIcon
{
    [newPopIcon retain];
    [popIcon release];
    popIcon = newPopIcon;
    
    [self updateImage];
}

- (NSSize)lastIconFrameSize
{
    return lastIconFrameSize;
}

- (void)setLastIconFrameSize:(NSSize)newLastIconFrameSize
{
    lastIconFrameSize = newLastIconFrameSize;
}

- (NSMenu *)menu
{
    return menu;
}

- (void)setMenu:(NSMenu *)newMenu
{
    [self setSelectedItem:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NSMenuDidSendActionNotification
                                                  object:menu];
    [newMenu retain];
    [menu release];
    menu = newMenu;

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(menuDidSendAction:)
                                                 name:NSMenuDidSendActionNotification
                                               object:menu];
    
    if ([menu numberOfItems] > 0) {
        [self setSelectedItem:[menu itemAtIndex:0]];
    }
}

- (NSMenuItem *)selectedItem
{
    return selectedItem;
}

- (void)setSelectedItem:(NSMenuItem *)newSelectedItem
{
    [selectedItem setState:NSOffState];
    
    [newSelectedItem retain];
    [selectedItem release];
    selectedItem = newSelectedItem;
    
    if ([self showsSelectedItem]) {
        [selectedItem setState:NSOnState];
    }
    
    if ([self displaysIconOfSelectedItem] && [selectedItem image]) {
        [self setIcon:[selectedItem image]];
    }
}

- (BOOL)canGetKeyboardFocus
{
    return canGetKeyboardFocus;
}

- (void)setCanGetKeyboardFocus:(BOOL)newCanGetKeyboardFocus
{
    canGetKeyboardFocus = newCanGetKeyboardFocus;
}

- (BOOL)showsMenuWhenIconClicked
{
    return showsMenuWhenIconClicked;
}

- (void)setShowsMenuWhenIconClicked:(BOOL)newShowsMenuWhenIconClicked
{
    showsMenuWhenIconClicked = newShowsMenuWhenIconClicked;
}

- (BOOL)showsSelectedItem
{
    return showsSelectedItem;
}

- (void)setShowsSelectedItem:(BOOL)newShowsSelectedItem
{
    showsSelectedItem = newShowsSelectedItem;
}

- (BOOL)displaysIconOfSelectedItem
{
    return displaysIconOfSelectedItem;
}

- (void)setDisplaysIconOfSelectedItem:(BOOL)newDisplaysIconOfSelectedItem
{
    displaysIconOfSelectedItem = newDisplaysIconOfSelectedItem;
}

@end
