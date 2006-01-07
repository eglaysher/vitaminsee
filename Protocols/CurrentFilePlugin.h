

/** The CurrentFilePlugin system allows other people to add their own code
 * to VitaminSEE through a standardized interface. The NSBundles that 
 * CurrentFilePlugins live in must:
 * * Have their principal class implement the protocol CurrentFilePlugin
 * * Provide info in the Info.plist file about the name (VSPluginName) and type
 *   (VSPluginType) of the plugin. Names should be unique, but the type should
 *   always be set to "CurrentFilePlugin".
 * * Provide info in their Info.plist file about the menu items needed so 
 *   VitaminSEE can build the menus without loading the plugin at startup.
 *
 * The following Info.plist keys are used:
 * * VSMenu - Top level container for all menu objects
 * * VSMenuItem - A container for an individual menu item.
 * * VSSubmenu - A container for a submenu. Contains VSMenuItems.


 * Here is an example of an entry that exports a menu item and a submenu with
 * two items:
 *
 * <key>VSMenu</key>
 * <array>
 *   <dict>
 *     <!-- WHEN A CALL TO -activatePluginWithFile:inWindow:context: is made,
 *          THIS DICTIONARY IS PASSED AS THE context: PARAMETER. You can store
 *          other things in this dictionary, like parameters or additional
 *          identifying information. -->
 *     <key>VSMenuName</key>
 *     <string>Title in menu</string>
 *   </dict>
 *   <dict>
 *     <-- This dictionary, being a submenu, is never passed as a context. -->
 *     <key>VSType</key>
 *     <string>VSSubmenu</string>
 *     <key>VSMenuName</key>
 *     <string>Submenu</string>
 *     <key>VSSubmenu</key>
 *     <array>
 *       <dict>
 *         <key>VSMenuName</key>
 *         <string>Do something</string>
 *       </dict>
 *       <dict>
 *         <key>VSMenuName</key>
 *         <string>Do something else</string>
 *         <key>UserKey</key>
 *         <string>Data in the hash used by the plugin</string>
 *       </dict>
 *     </array>
 *   </dict>
 * </array>
 *
 * There are several ways to use the CurrentFilePlugin to different effects:
 * * Having a inspector style window open and display information based on the
 *   current window. This can be done by responding to the 
 *   -activatePluginWithFile:inWindow:context: message, and then responding to 
 *   -currentImageSetTo: to update.
 * * Having a sheet or modal dialog pop up regarding an individual image. You 
 *   can have your -activatePluginWithFile:inWindow:context: implementation 
 *   spawn an object to handle a sheet (so that different windows won't be
 *   affected and so different windows can use the same plugin at the same
 *   time). Just ignore -currentImageSetTo: messages.
 *
 *
 *

 * If you are creating a mutating plugin that changes an image, consider 
 * providing an Automator action for it.
 *
 */
@protocol CurrentFilePlugin

/**
 * @param path The path to the currently displayed image at the time of 
 *             activation
 * @param window The currently active window that is displaying path. This
 *             parameter may be null in the case of full screen viewing.
 * @param context A copy of the menu item context dictionary that 
 */
-(void)activatePluginWithFile:(EGPath*)path inWindow:(NSWindow*)window
					  context:(NSDictionary*)context;

/** All plugins, after their initial activation, are sent this message.
 *
 */
-(void)currentImageSetTo:(EGPath*)path;

@end