//
//  MLBlockOperation.m
//  ViewControllers
//
//  Created by Joachim Kret on 10.04.2015.
//  Copyright (c) 2015 Joachim Kret. All rights reserved.
//

#import "MLBlockOperation.h"

#pragma mark - MLOperation

@interface MLOperation () {
@protected
    MLOperationState _state;
}

@property (nonatomic, readonly, strong) NSRecursiveLock * lock;
@property (nonatomic, readwrite, assign) MLOperationState state;

- (void)cancelOperation;
- (void)endBackgroundTask;

@end

#pragma mark - MLBlockOperation

@interface MLBlockOperation ()

@property (nonatomic, readonly, strong) NSMutableArray * arrayOfExecutionBlocks;
@property (nonatomic, readonly, strong) NSMutableArray * arrayOfCancellationBlocks;

@end

#pragma mark -

@implementation MLBlockOperation

+ (instancetype)blockOperationWithBlock:(void (^)(void))block {
    return [[[self class] alloc] initWithBlock:block];
}


#pragma mark Init

- (instancetype)initWithBlock:(void (^)(void))block {
    if (self = [self initWithIdentifier:nil]) {
        [self addExecutionBlock:block];
    }
    
    return self;
}

- (instancetype)initWithIdentifier:(NSString *)identifier {
    if (self = [super initWithIdentifier:identifier]) {
        _arrayOfExecutionBlocks = [[NSMutableArray alloc] init];
        _arrayOfCancellationBlocks = [[NSMutableArray alloc] init];
    }
    
    return self;
}

#pragma mark Blocks

- (NSArray *)executionBlocks {
    NSArray * executionBlocks = nil;
    
    [self.lock lock];
    executionBlocks = [NSArray arrayWithArray:_arrayOfExecutionBlocks];
    [self.lock unlock];
    
    return executionBlocks;
}

- (NSArray *)cancellationBlocks {
    NSArray * cancellationBlocks = nil;
    
    [self.lock lock];
    cancellationBlocks = [NSArray arrayWithArray:_arrayOfCancellationBlocks];
    [self.lock unlock];
    
    return cancellationBlocks;
}

- (void)addExecutionBlock:(void (^)(void))block {
    NSParameterAssert(block);
    
    [self.lock lock];
    
    if (!self.isFinished && !self.isCancelled && !self.isExecuting) {
        [_arrayOfExecutionBlocks addObject:block];
    }
    
    [self.lock unlock];
}

- (void)addCancellationBlock:(void (^)(void))block {
    NSParameterAssert(block);
    
    [self.lock lock];
    
    if (!self.isFinished && !self.isCancelled) {
        [_arrayOfCancellationBlocks addObject:block];
    }
    
    [self.lock unlock];
}

#pragma mark NSOpearion Subclass Methods

- (void)main {
    BOOL isAsynchronous = NO;
    
    [self.lock lock];
    isAsynchronous = self.isAsynchronous;
    NSAssert2(!isAsynchronous, @"Method: '%@' should be never called for asynchronous operation: %@", NSStringFromSelector(_cmd), [self description]);
    
    if (!isAsynchronous) {
        if (!self.isCancelled) {
            self.state = MLOperationStateExecuting;
            [self onExecute];
            
            for (void(^block)(void) in _arrayOfExecutionBlocks) {
                block();
            }
        }
    }
    
    [self.lock unlock];
}

- (void)start {
    [self.lock lock];
    
    if (!self.isCancelled) {
        self.state = MLOperationStateExecuting;
        [self onExecute];
        
        for (void(^block)(void) in _arrayOfExecutionBlocks) {
            block();
        }
    }
    
    [self.lock unlock];
}

- (void)cancelOperation {
    [super cancelOperation];

    for (void(^block)(void) in _arrayOfCancellationBlocks) {
        block();
    }
}

@end
