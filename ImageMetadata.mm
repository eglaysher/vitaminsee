//
//  ImageMetadata.m
//  CQView
//
//  Created by Elliot on 3/3/05.
//  Copyright 2005 Elliot Glaysher. All rights reserved.
//

#import "ImageMetadata.h"

#import "iptc.hpp"
#include <string>

using namespace std;

@implementation ImageMetadata

-(id)initWithPluginLayer:(PluginLayer*)pl
{
	// We don't really do or need anything.
	return [self init];
}

////////////////////////////////// EXIV2 WRAPPER! //////////////////////////////
-(NSMutableArray*)getKeywordsFromJPEGFile:(NSString*)file
{
//	NSLog(@"Trying to load keywords from %@", file);
	
	int rc;
	Exiv2::IptcData iptcData;
	try {
		rc = iptcData.read([file fileSystemRepresentation]);
	}
	catch(Exiv2::Error& e) {
		NSLog(@"Hey, there was an internal error in the Exiv2 library: %s", 
			  e.message().c_str());
	}
	
	if(rc)
	{
//		NSLog(@"Probelm reading file or no keywords found.");
		return nil;
	}
	
	NSMutableArray* keywords = [[NSMutableArray alloc] init];
	Exiv2::IptcData::iterator end = iptcData.end();
	for(Exiv2::IptcData::iterator md = iptcData.begin(); md != end; ++md)
	{
//		NSLog(@"Checking typename %s", md->tagName().c_str());
		if(md->tagName() == "Keywords")
		{
			// This entry is a keyword. Add it to our list.
			const char* keyVal = md->value().toString().c_str();
			NSString* keyword = [NSString stringWithCString:keyVal];
//			NSLog(@"Found keyword: %@", keyword);
			[keywords addObject:keyword];
		}
	}

	return [keywords autorelease];
}

-(void)setKeywords:(NSArray*)keywords forJPEGFile:(NSString*)file
{
//	NSLog(@"Saving keywords!");
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

////////////////////// PNG KEYWORDS
//+(NSMutableArray*)getKeywordsFromPNGFile:(NSString*)file
//{
//	char* filename = [file fileSystemRepresentation];
//	
//	// PNG stuff
//	png_uint w32, h32;
//	FILE* f;
//	png_structp png_ptr = NULL;
//	png_infop info_ptr = NULL;
//	
//	f = fopen(filename, "rb");
//	if(!f)
//		return nil;
//	
//	unsigned char buf[PNG_BYTES_TO_CHECK];
//	fread(buf, 1, PNG_BYTES_TO_CHECK, f);
//	if(!png_check_sig(buf, PNG_BYTES_TO_CHECK))
//	{
//		fclose(f);
//		return nil;
//	}
//	rewind(f);
//	
//	png_ptr = png_create_read_struct(PNG_LIBPNG_VER_STRING, NULL, NULL, NULL);
//	if(!png_ptr)
//	{
//		fclose(f);
//		return nil;
//	}
//	
//	info_ptr = png_create_info_struct(png_ptr);
//	if(!info_ptr)
//	{
//		png_destroy_read_struct(&png_ptr, NULL, NULL);
//		fclose(f);
//		return nil;
//	}
//	
//	if(setjmp(png_ptr->jmpbuf))
//	{
//		png_destroy_read_struct(&png_ptr, &info_ptr, NULL);
//		fclose(f);
//		return nil;		
//	}
//	
//	png_init_io(png_ptr, f);
//	png_read_info(png_ptr, info_ptr);
//	png_get_IHDR(png_ptr, info_ptr, (png_uint_32*)&w32, (png_uint_32*)&h32,
//				 &bit_depth, &color_type, &interlace_type, NULL, NULL);
//	
//	/* Comments are of the form:
//			text_ptr[0].key = "Title";
//			text_ptr[0].text = "{title}";
//			text_ptr[0].compression = PNG_TEXT_COMPRESSION_NONE;
//			text_ptr[1].key = "Keywords";
//			text_ptr[1].text = "{long list}";
//			text_ptr[1].compression = PNG_TEXT_COMPRESSION_xTXt;
//	 */
//	
//	png_textp text_ptr;
//	int num_text = 0;
//	png_get_text(png_ptr, info_ptr, &text_ptr, &num_text);
//	NSMutableArray* keywords = nil;
//	for(int i = 0; i < num_text; ++i)
//	{
//		if(strcmp(text_ptr[i]->key, "Keywords") == 0)
//		{
//			// fixme: deal with compressed 
//			keywords = [[NSString stringWithCString:text_ptr[i]->text] componentsSeparatedByString:@"\n"];
//		}
//	}
//
//	png_read_end(png_ptr, info_ptr);
//	png_destroy_read_struct(&png_ptr, &info_ptr, NULL);
//	fclose(f);
//	
//	return keywords;
//}
//
//+(void)setKeywords:(NSArray*)keywords forJPEGFile:(NSString*)file
//{
//	
//	
//}

@end
