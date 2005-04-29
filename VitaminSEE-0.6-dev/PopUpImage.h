//
//  PopUpImage.h
//  MenuViewTest
//
//  Created by Matt Gemmell on Sun Jan 26 2003.
//  Use however you like.
//

#import <Cocoa/Cocoa.h>

@interface PopUpImage : NSButton {
    NSImage *icon;			/* the main icon/image */
    NSImage *popIcon;			/* the popup-arrow (or whatever) image, displayed to the right of the icon */
    
    NSSize lastIconFrameSize;		/* size of the frame of the icon from the last time we were resized to fit */
    
    NSMenu *menu; 			/* the popup menu */
    NSMenuItem *selectedItem;	 	/* the last selected item */
    
    BOOL canGetKeyboardFocus; 		/* whether or not we accept keyboard focus, default YES */
    BOOL showsMenuWhenIconClicked;	/* whether or not we show the menu when the main icon is clicked, default YES */
    BOOL showsSelectedItem; 		/* whether or not we show a check-mark beside the last selected item in the menu, default NO */
    BOOL displaysIconOfSelectedItem;	/* whether or not we display the icon of the last selected item as our image, default NO */
}

/* Initializers */
- (id)initWithIcon:(NSImage *)theIcon popIcon:(NSImage*)thePopIcon; /* designated initializer */
- (id)initWithIcon:(NSImage *)theIcon;

/* Menu-related methods */
- (void)addItemWithTitle:(NSString *)title image:(NSImage *)img target:(id)trg action:(SEL)act;
- (void)addSeparator;
- (void)popUpMenuWithEvent:(NSEvent *)theEvent;
- (NSString *)titleOfSelectedItem;
- (int)indexOfSelectedItem;

/* Notification handlers */
- (void)menuDidSendAction:(id)notification;

/* Helper methods */
- (void)updateImage;
- (void)resizeToFit;

/* Accessors */
- (NSString *)title;

- (NSImage *)icon;
- (void)setIcon:(NSImage *)newIcon;

- (NSImage *)popIcon;
- (void)setPopIcon:(NSImage *)newPopIcon;

- (NSSize)lastIconFrameSize;
- (void)setLastIconFrameSize:(NSSize)newLastIconFrameSize;

- (NSMenu *)menu;
- (void)setMenu:(NSMenu *)newMenu;

- (NSMenuItem *)selectedItem;
- (void)setSelectedItem:(NSMenuItem *)newSelectedItem;

- (BOOL)canGetKeyboardFocus;
- (void)setCanGetKeyboardFocus:(BOOL)newCanGetKeyboardFocus;

- (BOOL)showsMenuWhenIconClicked;
- (void)setShowsMenuWhenIconClicked:(BOOL)newShowsMenuWhenIconClicked;

- (BOOL)showsSelectedItem;
- (void)setShowsSelectedItem:(BOOL)newShowsSelectedItem;

- (BOOL)displaysIconOfSelectedItem;
- (void)setDisplaysIconOfSelectedItem:(BOOL)newDisplaysIconOfSelectedItem;

@end
