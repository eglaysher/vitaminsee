
#import <Cocoa/Cocoa.h>

#import <pthread.h>

@class IconFamily;
@class VitaminSEEController;

@interface ThumbnailManager : NSObject {
	// TASK QUEUE:
	pthread_mutex_t taskQueueLock;
	NSMutableArray* thumbnailQueue;
	
	pthread_mutex_t imageScalingProperties;
		
	pthread_cond_t conditionLock;		
	
	NSImage* currentIconFamilyThumbnail;
	NSString* currentPath;
	int thumbnailLoadingPosition;
	
	id vitaminSEEController;
	
	bool shouldBuildIcon;
}

-(id)initWithController:(id)parrentController;


-(void)buildThumbnail:(NSString*)path;
-(void)clearThumbnailQueue;

-(void)setShouldBuildIcon:(BOOL)newShouldBuildIcon;
-(void)setThumbnailLoadingPosition:(int)newPosition;

-(NSString*)getCurrentPath;
-(NSImage*)getCurrentThumbnail;
-(void)clearThumbnailQueue;

@end
