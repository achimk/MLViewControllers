//
//  MLBaseResultsController.m
//  ViewControllers
//
//  Created by Joachim Kret on 09.03.2015.
//  Copyright (c) 2015 Joachim Kret. All rights reserved.
//

#import "MLBaseResultsController.h"

NSString * const MLResultsControllerMissingProtocolMethodException = @"MLResultsControllerMissingProtocolMethodException";

#pragma mark - MLBaseResultsController

@interface MLBaseResultsController () {
    NSPointerArray * _arrayOfObservers;
}

@end

#pragma mark -

@implementation MLBaseResultsController

@dynamic arrayOfObservers;

- (instancetype)init {
    if (self = [super init]) {
        _arrayOfObservers = [[NSPointerArray alloc] initWithOptions:NSPointerFunctionsWeakMemory | NSPointerFunctionsObjectPointerPersonality];
    }
    
    return self;
}

#pragma mark Observers

- (NSUInteger)indexOfObserver:(id)observer {
    __block NSUInteger index = NSNotFound;
    [_arrayOfObservers.allObjects enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (obj == observer) {
            index = idx;
            *stop = YES;
        }
    }];
    
    return index;
}

- (NSArray *)arrayOfObservers {
    [_arrayOfObservers compact]; // remove Null values
    return [_arrayOfObservers allObjects];
}

- (void)addResultsControllerObserver:(id <MLResultsControllerObserver>)observer {
    NSParameterAssert(observer);
    [_arrayOfObservers addPointer:(__bridge void *)(observer)];
}

- (void)removeResultsControllerObserver:(id <MLResultsControllerObserver>)observer {
    NSParameterAssert(observer);
    NSUInteger index = [self indexOfObserver:observer];
    if (NSNotFound != index) {
        [_arrayOfObservers removePointerAtIndex:index];
    }
}

#pragma mark MLResultsController

- (NSArray *)allObjects {
    @throw [self missingProtocolMethodExceptionWithSelector:_cmd];
}

- (NSArray *)sections {
    @throw [self missingProtocolMethodExceptionWithSelector:_cmd];
}

- (id)objectAtIndexPath:(NSIndexPath *)indexPath {
    @throw [self missingProtocolMethodExceptionWithSelector:_cmd];
}

- (NSIndexPath *)indexPathForObject:(id)object {
    @throw [self missingProtocolMethodExceptionWithSelector:_cmd];
}

#pragma mark Private Methods

- (NSException *)missingProtocolMethodExceptionWithSelector:(SEL)selector {
    return [NSException exceptionWithName:MLResultsControllerMissingProtocolMethodException
                                   reason:[NSString stringWithFormat:@"%@ class doesn't implement required method: %@", [self class], NSStringFromSelector(selector)]
                                 userInfo:nil];
}

@end
