//
//  MLAsynchronousOperation.m
//  ViewControllers
//
//  Created by Joachim Kret on 10.04.2015.
//  Copyright (c) 2015 Joachim Kret. All rights reserved.
//

#import "MLAsynchronousOperation.h"

#pragma mark - MLAsynchronousOperation

@implementation MLAsynchronousOperation

@synthesize state = _state;

#pragma mark Init

- (instancetype)initWithIdentifier:(NSString *)identifier {
    if (self = [super initWithIdentifier:identifier]) {
        _state = MLOperationStateReady;
    }
    
    return self;
}

#pragma mark Accessors

- (void)setState:(MLOperationState)state {
    [self.lock lock];
    
    if ([self stateTransitionIsValidFromState:_state toState:state]) {
        NSString * oldKeyPath = [self stringKeyPathForState:_state];
        NSString * newKeyPath = [self stringKeyPathForState:state];
        NSAssert1(oldKeyPath, @"Unsupported state old key path for state: %@", @(_state));
        NSAssert1(newKeyPath, @"Unsupported state new key path for state: %@", @(state));
        
        [self willChangeValueForKey:newKeyPath];
        [self willChangeValueForKey:oldKeyPath];
        
        _state = state;
        
        [self didChangeValueForKey:oldKeyPath];
        [self didChangeValueForKey:newKeyPath];
    }
    
    [self.lock unlock];
}

- (MLOperationState)state {
    return _state;
}

#pragma mark NSOperation Subclass Methods

- (BOOL)isAsynchronous {
    return YES;
}

- (BOOL)isReady {
    return (MLOperationStateReady == self.state && [super isReady]);
}

- (BOOL)isExecuting {
    return (MLOperationStateExecuting == self.state);
}

- (BOOL)isFinished {
    return (MLOperationStateFinished == self.state);
}

- (void)start {
    [self.lock lock];
    
    if (!self.isCancelled) {
        self.state = MLOperationStateExecuting;
        
        @autoreleasepool {
            [self onExecute];
        }
    }
    else {
        @autoreleasepool {
            [self onCancel];
        }
    }
    
    [self.lock unlock];
}

- (void)onExecute {
    self.state = MLOperationStateFinished;
}

- (void)onCancel {
    self.state = MLOperationStateFinished;
}

#pragma mark Private Methods

- (NSString *)stringKeyPathForState:(MLOperationState)state {
    static NSDictionary * mapping = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mapping = @{@(MLOperationStateReady)        : @"isReady",
                    @(MLOperationStateExecuting)    : @"isExecuting",
                    @(MLOperationStateFinished)     : @"isFinished"};
    });
    
    return mapping[@(state)];
}

- (BOOL)stateTransitionIsValidFromState:(MLOperationState)fromState toState:(MLOperationState)toState {
    switch (fromState) {
        case MLOperationStateReady: {
            switch (toState) {
                case MLOperationStateUnknown:
                case MLOperationStateReady: {
                    return NO;
                }
                case MLOperationStateExecuting: {
                    return YES;
                }
                case MLOperationStateFinished: {
                    return self.isCancelled;
                }
            }
        }
            
        case MLOperationStateExecuting: {
            switch (toState) {
                case MLOperationStateUnknown:
                case MLOperationStateReady:
                case MLOperationStateExecuting: {
                    return NO;
                }
                case MLOperationStateFinished: {
                    return YES;
                }
            }
        }
            
        case MLOperationStateFinished: {
            switch (toState) {
                case MLOperationStateUnknown:
                case MLOperationStateReady:
                case MLOperationStateExecuting:
                case MLOperationStateFinished: {
                    return NO;
                }
            }
        }
            
        case MLOperationStateUnknown: {
            switch (toState) {
                case MLOperationStateUnknown:
                case MLOperationStateExecuting: {
                    return NO;
                }
                case MLOperationStateReady: {
                    return YES;
                }
                case MLOperationStateFinished: {
                    return self.isCancelled;
                }
            }
        }
    }
}

@end
