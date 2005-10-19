
// Forward declarations
@class EGPath;
@protocol FileListDelegate;

//-----------------------------------------------------------------------------

/** FileLists are the interface components on the left side of the window that
 * present a number of files for the user to pick through. 
 *
 * FileLists are stored in seperate NSBundles and are detected through the
 * ComponentManager system. Each FileList bundle must have a principle class
 * that implements the FileListFactory protocol.
 *
 * @see ComponentManager
 * @see FileListFactory
 */
@protocol FileList

/** @name Delegate functions
 */
//@{

/** Sets the FileList delegate, which is used to pass commands back to the 
 * FileList owner.
 *
 * @see FileListDelegate
 */
-(void)setDelegate:(id<FileListDelegate>)delegate;
-(id<FileListDelegate>)delegate;

//@}

//-----------------------------------------------------------------------------

/** @name User Interface configuration.
 */
//@{

/** Function used to set up the next key states.
 */
-(void)connectKeyFocus:(id)nextFocus;

/** Returns the main view for the FileList. This is displayed by the 
 * application.
 */
-(NSView*)getView;

//@}

//-----------------------------------------------------------------------------
/** @name Setting Files and Directories Programatically
 */
//@{

/** Returns the current directory or NULL if this function isn't implemented 
 * because it doesn't make sense semantically for this plugin (in which case,
 * -canSetDirectory should be hardcoded to return NO.)
 *
 * @see -canSetDirectory
 */
-(EGPath*)directory;

/** Attempts to set the current directory. Returns YES on success and NO on
 * an internal error or if this function isn't implemented because it doesn't
 * make sense semantically for this plugin (in which case, -canSetDirectory
 * should be hardcoded to return NO.)
 *
 * @see -canSetDirectory
 */
-(BOOL)setDirectory:(EGPath*)newDirectory;

/** Returns the currently highlighted file, or NULL if no file is currently
 * selected.
 */
-(EGPath*)file;

/** Tell the plugin to try to select a certain file. Returns YES if it could
 * select the file or NO if it couldn't select the file or if the file isn't
 * in the current.
 */
-(BOOL)focusOnFile:(EGPath*)file;

/** Will change the current file to the next one in the internal state of the
 * FileList object, and will send a -setDisplayedFileTo: message to the 
 * designated FileListDelegate.
 *
 * FileLists that don't implement this shouldn't do anything. Nothing should
 * happen when the currently selected file is the last one.
 * 
 * @see -canGoNextFile
 */
-(void)goNextFile;

/** Will change the current file to the previous one in the internal state of 
 * the FileList object, and will send a -setDisplayedFileTo: message to the 
 * designated FileListDelegate
 *
 * FileLists that don't implement this shouldn't do anything. Nothing should
 * happen when the currently selected file is the first one.
 *
 * @see -canGoPreviousFile
 */
-(void)goPreviousFile;

/** Will step backwards through a list of previous directories, though
 * it could have a different semantic meaning (such as previous searches).
 *
 * @see -canGoBack
 */
-(void)goBack;

/** Will step forward through a list of previous directories, though
 * it could have a different semantic meaning (such as previous searches).
 *
 * @see -canGoFroward
 */
-(void)goForward;

//@}

//-----------------------------------------------------------------------------

/** @name User Interface Validation
 */
//@{

/** Determines if this plugin has the semantic idea of a "Current Directory".
 * Returning YES will enable menu items and toolbar items that set the current
 * directory, such as the "Home" or "Computer" entries. FileLists that respond
 * YES are expected to respond to -setDirectory:, and -directory.
 */
-(BOOL)canSetDirectory;

/** Checks if the "Next" Go menu item and toolbar item should be enabled. In
 * most FileLists, this should simply return YES unless the current file 
 * selected is the last one in the list.
 *
 * FileLists that want to totally disable should hard code a return value of
 * NO.
 */
-(BOOL)canGoNextFile;

/** Checks if the "Previous" Go menu item and toolbar item should be enabled. In
 * most FileLists, this should simply return YES unless the current file 
 * selected is the first one in the list.
 *
 * FileLists that want to totally disable should hard code a return value of
 * NO.
 */
-(BOOL)canGoPreviousFile;

/** Checks if the "Back" Go menu item and toolbar item should be enabled. In 
 * most FileLists, this means keeping track of the previous directories, though
 * it could have a different semantic meaning (such as previous searches).
 */
-(BOOL)canGoBack;

/** Checks if the "Forward" Go menu item and toolbar item should be enabled. In
 * most FileLists, this means keeping track of the previous directories, though
 * it could have a different semantic meaning.
 */
-(BOOL)canGoForward;

/** Responsible for setting the title information (and proxy icon if 
 * applicable) of a window. The window to set is passed in by the 
 * ViewerDocument.
 */
-(void)setWindowTitle:(NSWindow*)window;

//@}

@end

//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------

/** This protocol must be implemented by the Principle Class of a bundle that
 * represents a FileView.
 */
@protocol FileListFactory

/** -build, the single method in FileListFactory, simply returns an initialized
 * instance of the FileList contained in the current bundle.
 */
-(id<FileList>)build;

@end


//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------

/** An object that conforms to FileListDelegate is passed to your file list
* through the FileList's setDelegate: method.
*
* The FileListDelegate is a formal protocol as it has no optional functions.
*/
@protocol FileListDelegate
-(void)setDisplayedFileTo:(EGPath*)file;
-(EGPath*)currentFile;
@end

