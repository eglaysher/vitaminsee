//
//  BSTrampoline.m
//  VitaminSEE
//  Created by ThomasCastiglione 
//
//  License:
//  "Feel free to use this code for anything you want, although it'd be nice
// if you credited the original author (ThomasCastiglione)."

#import "BSTrampoline.h"

@implementation BSTrampoline

- (id)initWithEnumerator:(NSEnumerator *)inEnumerator mode:(int)operationMode {
    if (operationMode < kDoMode | operationMode > kRejectMode)
        [NSException raise:@"InvalidArgumentException" format:@"operationMode argument of initWithEnumerator:mode: was %d, outside %d-%d range.", operationMode, kDoMode, kRejectMode];
    enumerator = [inEnumerator retain];
    mode = operationMode;
    return self;
}

- (void)dealloc {
    [enumerator release];
    [super dealloc];
}


- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    if (mode > kCollectMode)	//For select&reject, return BOOL
        return [NSMethodSignature signatureWithObjCTypes:"c^v^c"];
    else			//For do&collect, return id (lowest common denominator)
        return [NSMethodSignature signatureWithObjCTypes:"@^v^c"];
}

- (void)forwardInvocation:(NSInvocation *)anInvocation {
    id index;
    //Next line unnecessary in kDoMode but the preprocessor doesn't like it if I add a test up here:/
    NSMutableArray *array = [[[NSMutableArray alloc] init] autorelease];	//The array to be returned
    id objRetVal;	//Temporaries for reading off the return value of the bounced method
    BOOL boolRetVal;
	
    /*
     * This is the core of the trampoline. invokeWithTarget: bounces the method to a member of the array,
     * which is fine for -do, but for -collect, -select and -reject there's some additional logic
     * needed. What we do is this:
     * COLLECT MODE
     * Get return value (making sure it's an object)
     * Add to return array
     * SELECT/REJECT MODE
     * Get return value
     * Test whether to add receiving object to array
     * Do so if necessary
     */
    while (index = [enumerator nextObject]) {
        [anInvocation invokeWithTarget:index];
        
        switch (mode) {
            case kDoMode:
                break;
            case kCollectMode:
                if (strcmp([[anInvocation methodSignature] methodReturnType], "@"))	//Decoded: id
                    [NSException raise:@"InvalidArgumentException" format:@"All array items must return objects for the given selector to use -collect. Return type is %s", [[anInvocation methodSignature] methodReturnType]];
                [anInvocation getReturnValue:&objRetVal];
                [array addObject:objRetVal];
                break;
            case kSelectMode:
            case kRejectMode:
                if (strcmp([[anInvocation methodSignature] methodReturnType], "c")) {	//Decoded: char/BOOL
                    [NSException raise:@"InvalidArgumentException" format:@"All array items must return bool for the given selector to use -select or -reject. Return type is %s", [[anInvocation methodSignature] methodReturnType]];
                }
                [anInvocation getReturnValue:&boolRetVal];
                if (boolRetVal && mode == kSelectMode || !boolRetVal && mode == kRejectMode)
                    [array addObject:index];
					break;
        }
    }
	
    /*
     * Here's our rather silly method of returning the array: we fix up the invocation to point
     * to our own getter method, and invoke that - so that when the flow of control resumes,
     * it's the last valid invocation. NSProxy is weird. Note that first we make sure that the
     * method signature is @^v^c to return an NSArray* - if we're in select or reject mode, the
     * default will be c^v^c, returning a BOOL. That would cause a segfault.
     */
    if (mode != kDoMode) {
        temp = array;
        [anInvocation initWithMethodSignature:[NSMethodSignature signatureWithObjCTypes:"@^v^c"]];
        [anInvocation setSelector:@selector(fakeInvocationReturningTempArray)];
        [anInvocation invokeWithTarget:self];
    }
}

- (NSArray *)fakeInvocationReturningTempArray {
    return temp;
}

@end