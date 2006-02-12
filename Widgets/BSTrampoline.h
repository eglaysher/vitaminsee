//
//  BSTrampoline.h
//  VitaminSEE
//
//  Created by ThomasCastiglione 
//
//  License:
//  "Feel free to use this code for anything you want, although it'd be nice
//   if you credited the original author (ThomasCastiglione)."

#import <Cocoa/Cocoa.h>

#import <Foundation/Foundation.h>

//It'd probably be nicer to use an enum here
#define kDoMode		0
#define kCollectMode	1
#define kSelectMode	2
#define kRejectMode	3

@interface BSTrampoline : NSProxy {
	id sampleObject; // Used to 
    NSEnumerator *enumerator;
    int mode;
    NSArray *temp;	//For returning from collect, select, reject
}

- (id)initWithEnumerator:(NSEnumerator *)inEnumerator mode:(int)operationMode
			sampleObject:(id)inSample;
- (NSArray *)fakeInvocationReturningTempArray;	//Like the name says
@end
