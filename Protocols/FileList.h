
@class EGPath;

/** An object that conforms to FileListCallback is passed to your file list
 * through the FileList's setDelegate: method.
 *
 * The FileListDelegate is a formal protocol as it has no optional functions.
 */
@protocol FileListDelegate
-(void)setDisplayedFileTo:(EGPath*)file;
-(EGPath*)currentFile;
@end

/** This protocol describes what a FileList must be able to do.
 *
 */
@protocol FileList

-(void)setDelegate:(id<FileListDelegate>)delegate;

/** Function used to set up the next key states.
 *
 */
-(void)connectKeyFocus:(id)nextFocus;

/** Getters and setters for the directory.
 */
-(BOOL)canSetDirectory;
-(NSString*)directory;
-(void)setDirectory:(EGPath*)newDirectory;

/** Getters and setters for individual files
 */
-(BOOL)canSetFile;
-(EGPath*)file;
-(void)setFile:(EGPath*)newFile;

/** Will focus the file viewer on the file, changing the directory if applicable.
 * Some FileList plugins won't be able to respond to this method, such as a 
 * image search FileList or a duplicate finder FileList, in which case 
 * canFocusOnSpecficFile should return NO.
 */
-(BOOL)canFocusOnSpecficFile;
-(void)focusOnFile:(NSString*)file;

/** Returns the file view.
 */
-(NSView*)getView;

/** The setWindowTitle: method is responsible for setting the title information
 * (and proxy icon if applicable) of a window. The window to set is passed in
 * by the ViewerDocument.
 */
-(void)setWindowTitle:(NSWindow*)window;

@end

/** This protocol must be implemented by the Principle Class of a bundle that
 * represents a FileView.
 */
@protocol FileListFactory
-(id<FileList>)build;
@end
