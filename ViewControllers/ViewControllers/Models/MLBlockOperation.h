//
//  MLBlockOperation.h
//  ViewControllers
//
//  Created by Joachim Kret on 10.04.2015.
//  Copyright (c) 2015 Joachim Kret. All rights reserved.
//

#import "MLOperation.h"

/**
 MLBlockOperation - block based operation class.
 */
@interface MLBlockOperation : MLOperation

@property (nonatomic, readonly, copy) NSArray * executionBlocks;    // Retruns copy of execution blocks.
@property (nonatomic, readonly, copy) NSArray * cancellationBlocks; // Returns copy of cancellation blocks.

// Common initializers.
+ (instancetype)blockOperationWithBlock:(void (^)(void))block;
- (instancetype)initWithBlock:(void (^)(void))block;

// Method for adding execution block (fire when operation transit to executing state).
- (BOOL)addExecutionBlock:(void (^)(void))block;

// Method for adding cancellation block (fire when operation is cancelled and transit to executing state).
- (BOOL)addCancellationBlock:(void (^)(void))block;

@end
