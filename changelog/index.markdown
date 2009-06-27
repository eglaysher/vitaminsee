---
layout: subpage
title: VitaminSEE Screenshots
---

<h4>VitaminSEE 0.7.1.2</h4> 
<ul> 
<li>Fixes a number of memory leaks; VitaminSEE was not properly releasing memory when a window was closed. This build fixes that.</li> 
</ul> 
<h4>VitaminSEE 0.7.1.1</h4> 
<ul> 
<li>When I upgraded to IconFamily 0.9.1, I forgot to port my changes that would restore a file&#8217;s modification date. Fix this so building a thumbnail of a file does set the modification date.</li> 
<li>Back/Forward will now focus on the file/folder you were on previously, instead of always starting at the beginning of the list.</li> 
</ul> 
<h4>VitaminSEE 0.7.1</h4> 
<ul> 
<li>Upgrade IconFamily to 0.9.1</li> 
<li>Make rename sheet handle extensions like the Save&#8230; dialogs do</li> 
<li>Add a fullscreen mode</li> 
<li>Don&#8217;t display document types that OSX treats as images, such as postscript<br /> 
  files, and PDFs.</li> 
</ul> 
<h4>VitaminSEE 0.7</h4> 
<ul> 
<li>Move to a multi-window interface.</li> 
<li>Windows now zoom and obey the positioning of the dock correctly.</li> 
<li>Work on UI responsiveness</li> 
<li>Remove &#8220;reload&#8221; option; instead monitor the filesystem like the Finder does</li> 
<li>Move the &#8220;rename&#8221; option from the Keywords window to its own menu item under File.</li> 
<li>Fix modification of keywords so that the creation date of a file isn&#8217;t modified when keywords are added or removed.</li> 
<li>First Universal Binary release.</li> 
</ul> 
<h4>VitaminSEE 0.6.4.1</h4> 
<ul> 
<li>Fix crash in the optimized thumbnailing code I wrote for 0.6.4.</li> 
</ul> 
<h4>VitaminSEE 0.6.4</h4> 
<ul> 
<li>You can now generate thumbnails, but not store them on disk. (The default behavior is to write thumbnails to disk.)</li> 
<li>Massivly reduce RAM consumption when building thumbnails.</li> 
<li>Bug fix: Program could get stuck on &#8220;Loading&#8230;&#8221; if computer was never named. (Kudos to &#8220;L S&#8221; for the bug report.)</li> 
<li>Add three Automator actions. Most importantly, there are actions to add and remove thumbnails so if you have some sort of image moving workflow, you can have thumbnails generated then, and not when you start VitaminSEE up.</li> 
<li>The Tiger GIF loader isn&#8217;t as resiliant against broken animated GIFs as<br /> 
  the Panther one was. Add a workaround that fixes *some* animated GIFs<br /> 
  that work under Panther. These images will play slowly, but at least<br /> 
  they&#8217;ll play.</li> 
</ul> 
<h4>VitaminSEE 0.6.3</h4> 
<ul> 
<li>Support all file types that Cocoa reports that we can open. This includes PDFs, Photoshop images, and (theoretically) some camera RAW formats under Tiger</li> 
<li>Set as Desktop Picture/Use Folder For Desktop Pictures: Set the current image as the desktop background picture or the contents of the currently selected folder for random backgrounds</li> 
<li>Translation fixes and AppleHelp translation by <a href="http://www.fan.gr.jp/~sakai/">Hiroto Sakai</a></li> 
<li>Small speed enhancements most people won&#8217;t notice</li> 
</ul> 
<h4>VitaminSEE 0.6.2</h4> 
<ul> 
<li>The Favorites toolbar item now correctly has a menu when in &#8220;Text Only&#8221; mode and in overflow mode.</li> 
<li>Fixed few places where UNIX paths were still being displayed to the user.</li> 
<li>Added an open with menu.</li> 
<li>Fixed behavior when handling symlinks; the directory drop down no longer gets screwed up when following a symlink.</li> 
<li>Use localized display name for the default Favorites location.</li> 
<li>Unicode keywords are now handled properly.</li> 
<li>Rough Japanese translation. There may be grammar errors here and there; I want to know about them. Props to the Japanese translation for Apple Preview and gqview for giving me a vocabulary lesson&#8230;</li> 
<li>Don&#8217;t smooth the image at Actual Size; it doesn&#8217;t do anything except slow things down. Apply smoothing only when shrinking or enlarging the image.</li> 
<li>In the same vein, don&#8217;t smooth the image when the unzoomed image will fit in the viewing area.</li> 
<li>Handle unmounting in a sane way.</li> 
</ul> 
<h4>VitaminSEE 0.6.1</h4> 
<ul> 
<li>Present the filesystem to the user like the Finder; do not expose the user to UNIXisms.
<ul> 
<li>Display paths like Macintosh HD:Users:name:&#8230; instead of /Users/name/</li> 
<li>Use Display names so localized folder names get displayed instead of the physical file name</li> 
<li>Hide system folders in &#8220;Macintosh HD&#8221; (This can be overridden with an option in the Advanced Preferences box)</li> 
<li>Have the file viewer rooted at &#8220;Computer&#8221; instead of &#8220;Macintosh HD&#8221;.</li> 
</ul> 
</li> 
<li>We now use <a href="http://www.brockerhoff.net/src/rbs.html">RBSplitView</a>. This:
<ul> 
<li>Fixed the bug where a user could resize the File List to a very small sliver and mess up the program&#8217;s internal logic, requiring a restart.</li> 
<li>Allows us to save the position and size of the File List.</li> 
<li>Allows us to add a &#8220;Show/Hide File List&#8221; entry in the View menu.</li> 
</ul> 
</li> 
<li>Added Next/Previous items to the Go menu. These are for navigation when the File List is hidden.</li> 
<li>Adding a thumbnail no longer changes the file&#8217;s modification time (as we are adding metadata to the filesystem; we are not touching the file&#8230;)</li> 
<li>Fixed problem where closing the VitaminSEE window and then opening the Sort Manager would result in enabled buttons in the Sort Manager despite the main window being closed.</li> 
<li>Fixed problem where thumbnails on remote SMB servers aren&#8217;t being displayed after generation.</li> 
<li>Fixed a bunch of memory leaks.</li> 
<li>Add UTIs to our Info.plist to support 10.4</li> 
</ul> 
<h4>VitaminSEE 0.6</h4> 
<ul> 
<li>Entering a new directory is much faster. On my computer, entering a directory of 746 images took 5 seconds in 0.5.3. Now it takes less then a second.</li> 
<li>ICNS and Windows Bitmap (BMP) support.</li> 
<li>Stop assuming people have a &#8220;~/Pictures&#8221; folder. Some people have broken out of Apple&#8217;s default hiearchy and we shouldn&#8217;t make assumptions.</li> 
<li>Finally get rid of that annoying graphical glitch where thumbnails aren&#8217;t drawn in certain circumstances.</li> 
<li>When an image won&#8217;t fit in the viewing area, the user can now drag the image around with a hand cursor like they can in Preview.</li> 
<li>Change &#8220;Sort Manager&#8221; preferences to &#8220;Favorites.&#8221; These paths are now used both in the Sort Manager and in the new &#8220;Favorite Locations&#8221; menu in the &#8220;Go&#8221; menu and its corresponding toolbar item.</li> 
<li>Files with the wrong extension (JPEG files ending in GIF, PNG files ending in JPEG) are loaded, instead of raising an error.</li> 
<li>Move, Copy and Rename operations now check if they are overwriting a file and warn the user.</li> 
<li>Move, Copy and Rename are now undoable. Undo for delete isn&#8217;t implemented yet. (I&#8217;m having problems figuring out the trash system, but I&#8217;ll get it eventually).</li> 
</ul> 
<h4>VitaminSEE 0.5.3</h4> 
<ul> 
<li>Make SortManager prettier and resizable</li> 
<li>Allow reordering of paths in Sort Manager Preferences</li> 
<li>Ability to disable preloading of images</li> 
<li>Cosmetic changes</li> 
</ul> 
<h4>VitaminSEE 0.5.2</h4> 
<ul> 
<li>You can now drag image files and folders to the VitaminSEE icon. I&#8217;ve registered VitaminSEE as a handler for folders, JPEGS, GIFs and TIFFs.</li> 
</ul> 
<h4>VitaminSEE 0.5.1</h4> 
<ul> 
<li>A critical memory leak was fixed in the thumbnail generation code.</li> 
<li>Filesize fixed for files greter then a megabyte.</li> 
</ul> 
<h4>VitaminSEE 0.5 Final</h4> 
<ul> 
<li>Cosmetic changes (HIG compliance)</li> 
<li>Add a &#8220;Known Issues&#8221; page to the help</li> 
<li>Make the GPL a Help menu item</li> 
</ul> 
<h4>VitaminSEE 0.5 Release Canidate 2</h4> 
<ul> 
<li>Fixed deadlock that would occur every half hour or so</li> 
</ul>
