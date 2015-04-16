//
//  MLOperation.h
//  ViewControllers
//
//  Created by Joachim Kret on 10.04.2015.
//  Copyright (c) 2015 Joachim Kret. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

// Default error domain for MLOperation.
extern NSString * const MLOperationErrorDomain;

/**
 Operation's error codes.
 */
typedef NS_ENUM(NSUInteger, MLOperationErrorCode) {
    MLOperationErrorCodeCancelled   = 0 // Operation was cancelled.
};

/**
 MLOperation - base operation class (non-concurrent).
 */
@interface MLOperation : NSOperation

@property (nonatomic, readonly, copy) NSString * identifier;    // Operation's unique identifier.
@property (nonatomic, readonly, assign) UIBackgroundTaskIdentifier backgroundTaskIdentifier;    // Background indetifier task for expiration handler.
@property (nonatomic, readonly, strong) NSRecursiveLock * lock; // Operation's lock.
@property (nonatomic, readwrite, strong) NSError * error;   // Encountered error during operation.
@property (nonatomic, readwrite, strong) id result; // Operation's result.
@property (nonatomic, readwrite, strong) dispatch_queue_t completionQueue;  // Completion queue on which completion block will be called (default is nil and calls completion block on main queue).
@property (nonatomic, readwrite, strong) dispatch_group_t completionGroup; // Completion group on which completion block will operate (default is nil and performs completion block on dynamically created dispatch group).

// Common initializers.
+ (instancetype)operation;
+ (instancetype)operationWithIdentifier:(NSString *)identifier;
- (instancetype)initWithIdentifier:(NSString *)identifier;

// Set completion block with success or failure handler.
- (void)setCompletionBlockWithSuccess:(void (^)(MLOperation * operation, id result))success
                              failure:(void (^)(MLOperation * operation, NSError * error))failure;

// Setup background task with expiration handler.
- (void)setShouldExecuteAsBackgroundTaskWithExpirationHandler:(void (^)(void))handler;

@end

/**
 MLOperation (MLSubclassOnly)
 */
@interface MLOperation (MLSubclassOnly)

// Subclass to provide custom implementation for onExecute and onCancel methods.
// Both methods are wrapped by using NSRecursiveLock locking.
- (void)onExecute;
- (void)onCancel;

@end

/**
 MLOperation (MLBatchOperations)
 */
@interface MLOperation (MLBatchOperations)

// Batch of operations - returns an array of operations with complete operation dependency setup.
+ (NSArray *)batchOfOperations:(NSArray *)operations
                 progressBlock:(void (^)(NSUInteger numberOfFinishedOperations, NSUInteger totalNumberOfOperations))progressBlock
               completionBlock:(void (^)(NSArray * operations))completionBlock;

@end