//
//  ImageMetadata.m
//  CQView
//
//  Created by Elliot on 3/3/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "ImageMetadata.h"

#import <Exiv2/iptc.hpp>
//#import <Exiv2/

#include <string>

using namespace std;

@implementation ImageMetadata

+(NSMutableArray*)getKeywordsFromFile:(NSString*)file
{
	NSLog(@"Trying to load keywords from %@", file);
	
	Exiv2::IptcData iptcData;
	int rc = iptcData.read([file fileSystemRepresentation]);
	if(rc)
	{
		NSLog(@"Probelm reading file or no keywords found.");
		return nil;
	}
	
	NSMutableArray* keywords = [[NSMutableArray alloc] init];
	Exiv2::IptcData::iterator end = iptcData.end();
	for(Exiv2::IptcData::iterator md = iptcData.begin(); md != end; ++md)
	{
		NSLog(@"Checking typename %s", md->tagName().c_str());
		if(md->tagName() == "Keywords")
		{
			// This entry is a keyword. Add it to our list.
			const char* keyVal = md->value().toString().c_str();
			NSString* keyword = [NSString stringWithCString:keyVal];
			NSLog(@"Found keyword: %@", keyword);
			[keywords addObject:keyword];
		}
	}

	return [keywords autorelease];
}

+(void)setKeywords:(NSArray*)keywords forFile:(NSString*)file
{
	NSLog(@"Saving keywords!");
	// First, read the IPTC data for the file. We don't want to clobber other
	// metadata.
	Exiv2::IptcData iptcData;
	// Ignore return value. Doesn't matter if there is no IPTC data...
	iptcData.read([file fileSystemRepresentation]);
	
	// Second, go through and remove all keyword entries
	Exiv2::IptcKey keywordsKey("Iptc.Application2.Keywords");
	Exiv2::IptcData::iterator keywordIter;
	while((keywordIter = iptcData.findKey(keywordsKey)) != iptcData.end())
		iptcData.erase(keywordIter);
	
	// Now, add all keywords
	NSEnumerator* e = [keywords objectEnumerator];
	NSString* keyword;
	while(keyword = [e nextObject])
	{
		Exiv2::Value::AutoPtr v = Exiv2::Value::create(Exiv2::string);
		v->read([keyword UTF8String]);
		iptcData.add(keywordsKey, v.get());
	}
	
	// write to file.
	iptcData.write([file fileSystemRepresentation]);
}

@end
