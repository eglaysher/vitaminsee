/*
 *  Util.m
 *  WallSelector
 *
 *  Created by Elliot Glaysher on 1/14/05.
 *  Copyright 2005 Elliot Glaysher. All rights reserved.
 *
 */

#import "DesktopBackground.h"

static void setProperties(NSDictionary* dict);
static void setupFirstTime(NSMutableDictionary* display);
static NSDictionary* buildScreenList();

void setDesktopBackgroundToFile(NSString* path)
{
	NSMutableDictionary* display = [NSMutableDictionary dictionary];

	// Build the default settings if 
	id desktopDomain = [[NSUserDefaults standardUserDefaults] 
		persistentDomainForName:@"com.apple.desktop"];
	if(!desktopDomain)
	{	
		setupFirstTime(display);
	}
	
	// Set things related to making sure the user interface on the Desktop screen
	// displays properly.
	[display setObject:@"Never" forKey:@"Change"];
	[display setObject:[path stringByDeletingLastPathComponent] forKey:@"ChangePath"];
	[display setObject:[path stringByDeletingLastPathComponent] forKey:@"ChooseFolderPath"];
	[display setObject:[[path stringByDeletingLastPathComponent] lastPathComponent] forKey:@"CollectionString"];
	
	[display setObject:path forKey:@"ImageFilePath"];
	
	// Build an alias to the image file
	// Code snipet for turning NSURL into an alias from the Growl additions.
	NSURL* url = [NSURL fileURLWithPath:path];
	NSData* aliasData = nil;
	FSRef fsref;
	if (CFURLGetFSRef((CFURLRef)url, &fsref)) {
		AliasHandle alias = NULL;
		OSStatus    err   = FSNewAlias(/*fromFile*/ NULL, &fsref, &alias);
		if (err != noErr) {
			NSLog(@"setDesktopBackgroundToFile: FSNewAlias for %@ returned %li. Can't set ImageFileAlias.", path, (long)err);
		} else {
			HLock((Handle)alias);
			
			aliasData = [NSData dataWithBytes:*alias length:GetHandleSize((Handle)alias)];
			[display setObject:aliasData forKey:@"ImageFileAlias"];
			
			HUnlock((Handle)alias);
			DisposeHandle((Handle)alias);
		}
	}
	
	setProperties(display);
}

void setDesktopBackgroundToFolder(NSString* pathToFolder)
{
	NSMutableDictionary* display = [NSMutableDictionary dictionary];
	
	// Now we check to see if we aren't in multi-wallpaper mode. If we aren't,
	// then set it to the last tag and message preferenceCenter (if it exists)
	id desktopDomain = [[NSUserDefaults standardUserDefaults] 
		persistentDomainForName:@"com.apple.desktop"];
	if(desktopDomain)
	{
		id desktopDefaults = [[desktopDomain objectForKey:@"Background"] 
			objectForKey:@"default"];
		id change = [desktopDefaults objectForKey:@"Change"];
		id timerPopUpTag = [desktopDefaults objectForKey:@"TimerPopUpTag"];
		if(!change || !timerPopUpTag)
		{
			// This user has a com.apple.desktop preference domain, but doesn't
			// have a "Change" or a "TimerPopUpTag" property. Assume major 
			// brain damage and setup for the first time.
			setupFirstTime(display);
		}
		else if([change isEqualToString:@"Never"])
		{
			// The user is currently in single image wallpaper mode, but has
			// previous settings. Load them.
			int tag = [timerPopUpTag intValue];
			
			if(tag >= 0 && tag < 9)
				[display setObject:@"TimeInterval" forKey:@"Change"];
			else if(tag == 9)
				[display setObject:@"Login" forKey:@"Change"];
			else if(tag == 10)
				[display setObject:@"Wakeup" forKey:@"Change"];
		}
	}
	else
	{
		// zOMG NONE! This user doesn't have defaults for com.apple.desktop! We
		// need to build display settings from scratch for this user!
		setupFirstTime(display);
	}
	
	[display setObject:pathToFolder forKey:@"ChangePath"];
	[display setObject:pathToFolder forKey:@"ChooseFolderPath"];
	[display setObject:[pathToFolder lastPathComponent] forKey:@"CollectionString"];
	setProperties(display);	
}

static void setProperties(NSDictionary* dict)
{
	NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];

	// First we set the new settings on each wallpaper...
	// Now we just set up the details for everything...
	id desktop = [[[defaults persistentDomainForName:@"com.apple.desktop"]
		mutableCopy] autorelease];
	id background;
	if(!desktop)
	{
		desktop = [NSMutableDictionary dictionary];
		background = buildScreenList();
	}
	else
		background = [[[desktop objectForKey:@"Background"] mutableCopy] 
			autorelease];
	int i, n = [background count];
	id displayIDs = [background allKeys];
	for (i = 0; i < n; i++) {
		id did = [displayIDs objectAtIndex:i];
		id display = [[[background objectForKey:did] mutableCopy] autorelease];
		
		// For each key and object in dict, set them in display...
		NSEnumerator* e = [dict keyEnumerator];
		NSString* key;
		while(key = [e nextObject])
		{
			[display setObject:[dict objectForKey:key]
										forKey:key];
										
		}
		
		[background setObject:display forKey:did];
	}
	[desktop setObject:background forKey:@"Background"];

	[defaults removePersistentDomainForName:@"com.apple.desktop"];
	[defaults setPersistentDomain:desktop forName:@"com.apple.desktop"];

	// Synchronize the com.apple.desktop in memory with the one on disk...
	if([defaults synchronize] == NO)
		NSLog(@"Synchronization failed!?");

	// Make sure the window server knows that we've changed the background.
	[[NSDistributedNotificationCenter defaultCenter]
		postNotificationName:@"com.apple.desktop"
					  object:@"BackgroundChanged"];
}

static void setupFirstTime(NSMutableDictionary* display)
{
	[display setObject:@"TimeInterval" forKey:@"Change"];
	[display setObject:[NSNumber numberWithFloat:60] forKey:@"ChangeTime"];
	[display setObject:[NSNumber numberWithInt:2] forKey:@"TimerPopUpTag"];
	[display setObject:@"Crop" forKey:@"Placement"];
	[display setObject:[NSNumber numberWithInt:1] forKey:@"PlacementKeyTag"];
	[display setObject:[NSNumber numberWithBool:YES] forKey:@"Random"];
}

// Build a dictionary with 1+number of screen entries. Each will consist of an
// NSMutableDictionary.
//
// This code will probably be only invoked once, if ever.
static NSDictionary* buildScreenList()
{
	NSMutableDictionary* background = [[[NSMutableDictionary alloc] init] autorelease];

	// There will always be a default entry...
	[background setObject:[NSMutableDictionary dictionary] forKey:@"default"];

	NSEnumerator *e = [[NSScreen screens] objectEnumerator];
	NSScreen *screen;
	while(screen = [e nextObject])
	{
		NSNumber* screenID = [[screen deviceDescription] objectForKey:@"NSScreenNumber"];
		if(screenID)
		{
			// Add a dictionary.
			[background setObject:[NSMutableDictionary dictionary] forKey:[screenID stringValue]];
		}
	}
	
	return background;
}