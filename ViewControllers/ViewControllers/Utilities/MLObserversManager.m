//
//  MLObserversManager.m
//  ViewControllers
//
//  Created by Joachim Kret on 22.11.2014.
//  Copyright (c) 2014 Joachim Kret. All rights reserved.
//

#import "MLObserversManager.h"
#import <objc/runtime.h>

#pragma mark - MLObserversManager

@interface MLObserversManager () {
    NSPointerArray * _arrayOfObservers;
    Protocol * _protocol;
}

@end

#pragma mark -

@implementation MLObserversManager

#pragma mark Init

- (instancetype)initWithObservers:(NSArray *)observers {
    return [self initWithProtocol:nil observers:observers];
}

- (instancetype)initWithProtocol:(Protocol *)protocol observers:(NSArray *)observers {
    if (self = [super init]) {
        _mode = MLObserversManagerModeDefault;
        _protocol = protocol;
        _arrayOfObservers = [[NSPointerArray alloc] initWithOptions:NSPointerFunctionsWeakMemory | NSPointerFunctionsObjectPointerPersonality];
        
        for (id observer in observers) {
            [self registerObserver:observer];
        }
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

- (void)registerObserver:(id)observer {
    NSParameterAssert(observer);
    NSAssert1(!_protocol || [observer conformsToProtocol:_protocol], @"Observer MUST conforms to protocol: %@", NSStringFromProtocol(_protocol));
    [_arrayOfObservers addPointer:(__bridge void *)(observer)];
}

- (void)unregisterObserver:(id)observer {
    NSParameterAssert(observer);
    NSUInteger index = [self indexOfObserver:observer];
    if (NSNotFound != index) {
        [_arrayOfObservers removePointerAtIndex:index];
    }
}

- (void)unregisterAllObservers {
    NSArray * arrayOfObservers = [self arrayOfObservers];
    for (id observer in arrayOfObservers) {
        [self unregisterObserver:observer];
    }
}

#pragma mark Invoke Observers

- (BOOL)respondsToSelector:(SEL)aSelector {
    NSArray * arrayOfObservers = [self arrayOfObservers];
    for (id observer in arrayOfObservers) {
        if ([observer respondsToSelector:aSelector]) {
            return YES;
        }
    }
    
    return [super respondsToSelector:aSelector];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    NSMethodSignature * result = [super methodSignatureForSelector:aSelector];
    
    if (result) {
        return result;
    }
    
    if (_protocol) {
        //Looking for a required method
        struct objc_method_description desc = protocol_getMethodDescription(_protocol, aSelector, YES, YES);
        
        //Looking for a optional method
        if (NULL == desc.name) {
            desc = protocol_getMethodDescription(_protocol, aSelector, NO, YES);
        }
        
        if (NULL != desc.name) {
            return [NSMethodSignature signatureWithObjCTypes:desc.types];
        }
    }
    else {
        // Find first method signature in observers
        NSArray * arrayOfObservers = [self arrayOfObservers];
        for (id observer in arrayOfObservers) {
            if ([observer respondsToSelector:aSelector]) {
                return [observer methodSignatureForSelector:aSelector];
            }
        }
    }
    
    //Couldn't find method, raise exception: NSInvalidArgumentException
    [self doesNotRecognizeSelector:aSelector];
    return nil;
}

- (void)forwardInvocation:(NSInvocation *)anInvocation {
    SEL selector = [anInvocation selector];
    
    NSArray * arrayOfObservers = [self arrayOfObservers];
    for (id observer in arrayOfObservers) {
        if ([observer respondsToSelector:selector]) {
            [anInvocation invokeWithTarget:observer];
            
            if (MLObserversManagerModeForwardFirst == self.mode) {
                break;
            }
        }
    }
}

@end
