//
//  MLBlockOperation.h
//  ViewControllers
//
//  Created by Joachim Kret on 10.04.2015.
//  Copyright (c) 2015 Joachim Kret. All rights reserved.
//

#import "MLOperation.h"

/**
 MLBlockOperation - block based operation class (non-concurrent).
 */
@interface MLBlockOperation : MLOperation

@property (nonatomic, readonly, copy) NSArray * executionBlocks;    // Retruns copy of execution blocks.
@property (nonatomic, readonly, copy) NSArray * cancellationBlocks; // Returns copy of cancellation blocks.

// Common initializers.
+ (instancetype)blockOperationWithBlock:(void (^)(void))block;
- (instancetype)initWithBlock:(void (^)(void))block;

// Method for adding execution block (fire when operation transit to isExecuting state).
- (void)addExecutionBlock:(void (^)(void))block;

// Method for adding cancellation block (fire when cancel method trigerred).
- (void)addCancellationBlock:(void (^)(void))block;

@end
