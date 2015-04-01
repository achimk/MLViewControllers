//
//  MLBaseResultsController.m
//  ViewControllers
//
//  Created by Joachim Kret on 09.03.2015.
//  Copyright (c) 2015 Joachim Kret. All rights reserved.
//

#import "MLBaseResultsController.h"

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
    return [_arrayOfObservers.allObjects indexOfObject:observer];
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
    NSAssert1(NO, @"You must override method: '%@' in subclass.", NSStringFromSelector(_cmd));
    return nil;
}

- (NSArray *)sections {
    NSAssert1(NO, @"You must override method: '%@' in subclass.", NSStringFromSelector(_cmd));
    return nil;
}

- (id)objectAtIndexPath:(NSIndexPath *)indexPath {
    NSAssert1(NO, @"You must override method: '%@' in subclass.", NSStringFromSelector(_cmd));
    return nil;
}

- (NSIndexPath *)indexPathForObject:(id)object {
    NSAssert1(NO, @"You must override method: '%@' in subclass.", NSStringFromSelector(_cmd));
    return nil;
}

@end
