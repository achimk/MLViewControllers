//
//  MLOperation.m
//  ViewControllers
//
//  Created by Joachim Kret on 10.04.2015.
//  Copyright (c) 2015 Joachim Kret. All rights reserved.
//

#import "MLOperation.h"
#if DEBUG
#import <libkern/OSAtomic.h>
#endif

NSString * const MLOpetationQueueName       = @"com.controllers.operation.queue";
NSString * const MLOperationLockName        = @"com.controllers.operation.lock";
NSString * const MLOperationErrorDomain     = @"MLOperationErrorDomain";

static dispatch_queue_t MLOperationDispatchQueue() {
    static dispatch_queue_t dispatchQueue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dispatchQueue = dispatch_queue_create([MLOpetationQueueName cStringUsingEncoding:NSUTF8StringEncoding], DISPATCH_QUEUE_CONCURRENT);
    });
    
    return dispatchQueue;
}

static dispatch_group_t MLOperationDispatchGroup() {
    static dispatch_group_t dispatchGroup = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dispatchGroup = dispatch_group_create();
    });
    
    return dispatchGroup;
}

#pragma mark - MLOperation

@interface MLOperation () {
@protected
#if DEBUG
    int32_t _cancelOnce;
#endif
    MLOperationState _state;
}

@property (nonatomic, readonly, strong) NSRecursiveLock * lock;
@property (nonatomic, readwrite, strong) NSError * error;
@property (nonatomic, readwrite, assign) MLOperationState state;

- (void)endBackgroundTask;

@end

#pragma mark -

@implementation MLOperation

+ (instancetype)operation {
    return [[[self class] alloc] init];
}

+ (instancetype)operationWithIdentifier:(NSString *)identifier {
    return [[[self class] alloc] initWithIdentifier:identifier];
}

#pragma mark Init / Dealloc

- (instancetype)init {
    return [self initWithIdentifier:nil];
}

- (instancetype)initWithIdentifier:(NSString *)identifier {
    if (self = [super init]) {
        _state = MLOperationStateUnknown;
        _backgroundTaskIdentifier = UIBackgroundTaskInvalid;
        _identifier = (identifier && identifier.length) ? [identifier copy] : [[NSUUID UUID] UUIDString];
        _lock = [[NSRecursiveLock alloc] init];
        _lock.name = MLOperationLockName;
    }
    
    return self;
}

- (void)dealloc {
    [self endBackgroundTask];
}

#pragma mark Accessors

- (void)setError:(NSError *)error {
    [self.lock lock];
    _error = error;
    [self.lock unlock];
}

- (MLOperationState)state {
    if (self.isReady) {
        return MLOperationStateReady;
    }
    else if (self.isExecuting) {
        return MLOperationStateExecuting;
    }
    else if (self.isFinished) {
        return MLOperationStateFinished;
    }
    else {
        return MLOperationStateUnknown;
    }
}

- (NSString *)description {
    NSString * description = nil;
    
    [self.lock lock];
    description = [NSString stringWithFormat:@"<%@: %p, identifier: %@, state: %@, cancelled: %@, asynchronous: %@>",
                   NSStringFromClass([self class]),
                   self,
                   self.identifier,
                   [self stringFromCurrentState],
                   ((self.isCancelled) ? @"YES" : @"NO"),
                   ((self.isAsynchronous) ? @"YES" : @"NO")];
    [self.lock unlock];
    
    return description;
}

#pragma mark NSOperation Subclass Methods

- (BOOL)isAsynchronous {
    return NO;
}

- (void)main {
    [self.lock lock];
    
    if (!self.isCancelled) {
        [self onExecute];
    }

    if (self.isCancelled) {
        [self onCancel];
    }
    
    [self.lock unlock];
}

- (void)cancel {
    [self.lock lock];
    
    if (!self.isFinished && !self.isCancelled) {
#if DEBUG
        if (!OSAtomicCompareAndSwap32(0, 1, &_cancelOnce)) {
            NSAssert(NO, @"%@: '%@' method called more than once!", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
        }
#endif
        [super cancel];
        
        if (!self.error) {
            self.error = [NSError errorWithDomain:MLOperationErrorDomain
                                             code:MLOperationErrorCodeCancelled
                                         userInfo:nil];
        }
    }
    
    [self.lock unlock];
}

#pragma mark Subclass Methods

- (void)onExecute {
    // Subclasses can override this method to provide custom implementation on execute operation
}

- (void)onCancel {
    // Subclasses can override this method to provide custom implementation on cancel operation
}

#pragma mark Completion Block

- (void)setCompletionBlock:(void (^)(void))completionBlock {
    [self.lock lock];
    
    if (completionBlock) {
        __weak typeof(self)weakSelf = self;
        [super setCompletionBlock:^{
            __strong typeof(self)strongSelf = weakSelf;
            dispatch_queue_t queue = (strongSelf.completionQueue) ?: MLOperationDispatchQueue();
            dispatch_group_t group = (strongSelf.completionGroup) ?: MLOperationDispatchGroup();
            dispatch_group_async(group, queue, completionBlock);
            dispatch_group_notify(group, MLOperationDispatchQueue(), ^{
                [strongSelf setCompletionBlock:nil];
            });
        }];
    }
    else {
        [super setCompletionBlock:nil];
    }
    
    [self.lock unlock];
}

- (void)setCompletionBlockWithSuccess:(void (^)(MLOperation *))success failure:(void (^)(MLOperation *))failure {
    __weak typeof(self)weakSelf = self;
    [self setCompletionBlock:^{
        __strong typeof(weakSelf)strongSelf = weakSelf;
        dispatch_queue_t queue = (strongSelf.completionQueue) ?: dispatch_get_main_queue();
        dispatch_group_t group = (strongSelf.completionGroup) ?: dispatch_group_create();
        
        if (strongSelf.completionGroup) {
            dispatch_group_enter(strongSelf.completionGroup);
        }
    
        if (strongSelf.error) {
            if (failure) {
                dispatch_group_async(group, queue, ^{
                    failure(strongSelf);
                });
            }
        }
        else {
            if (success) {
                dispatch_group_async(group, queue, ^{
                    success(strongSelf);
                });
            }
        }
        
        if (strongSelf.completionGroup) {
            dispatch_group_leave(strongSelf.completionGroup);
        }
    }];
}

#pragma mark Background Task

- (void)setShouldExecuteAsBackgroundTaskWithExpirationHandler:(void (^)(void))handler {
    [self.lock lock];
    
    if (UIBackgroundTaskInvalid == _backgroundTaskIdentifier) {
        __weak typeof(self)weakSelf = self;
        _backgroundTaskIdentifier = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
            __strong typeof(weakSelf)strongSelf = weakSelf;
            
            if (handler) {
                handler();
            }
            
            if (strongSelf) {
                [strongSelf cancel];
                [strongSelf endBackgroundTask];
            }
        }];
    }
    
    [self.lock unlock];
}

- (void)endBackgroundTask {
    if (_backgroundTaskIdentifier) {
        [[UIApplication sharedApplication] endBackgroundTask:_backgroundTaskIdentifier];
        _backgroundTaskIdentifier = UIBackgroundTaskInvalid;
    }
}

#pragma mark Private Methods

- (NSString *)stringFromCurrentState {
    static NSDictionary * mapping = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mapping = @{@(MLOperationStateUnknown)      : @"Unknown",
                    @(MLOperationStateReady)        : @"Ready",
                    @(MLOperationStateExecuting)    : @"Executing",
                    @(MLOperationStateFinished)     : @"Finished"};
    });
    
    return (mapping[@(self.state)]) ?: @"";
}

@end

#pragma mark - MLOperation (MLBatchOperations)

@implementation MLOperation (MLBatchOperations)

+ (NSArray *)batchOfOperations:(NSArray *)operations
                 progressBlock:(void (^)(NSUInteger numberOfFinishedOperations, NSUInteger totalNumberOfOperations))progressBlock
               completionBlock:(void (^)(NSArray * operations))completionBlock {
    if (!operations || [operations count] == 0) {
        return @[[NSBlockOperation blockOperationWithBlock:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completionBlock) {
                    completionBlock(@[]);
                }
            });
        }]];
    }
    
    __block dispatch_group_t group = dispatch_group_create();
    NSBlockOperation *batchedOperation = [NSBlockOperation blockOperationWithBlock:^{
        dispatch_group_notify(group, dispatch_get_main_queue(), ^{
            if (completionBlock) {
                completionBlock(operations);
            }
        });
    }];
    
    for (MLOperation * operation in operations) {
        operation.completionGroup = group;
        void (^originalCompletionBlock)(void) = [operation.completionBlock copy];
        __weak __typeof(operation)weakOperation = operation;
        operation.completionBlock = ^{
            __strong __typeof(weakOperation)strongOperation = weakOperation;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wgnu"
            dispatch_queue_t queue = strongOperation.completionQueue ?: dispatch_get_main_queue();
#pragma clang diagnostic pop
            dispatch_group_async(group, queue, ^{
                if (originalCompletionBlock) {
                    originalCompletionBlock();
                }
                
                NSUInteger numberOfFinishedOperations = [[operations indexesOfObjectsPassingTest:^BOOL(id op, NSUInteger __unused idx,  BOOL __unused *stop) {
                    return [op isFinished];
                }] count];
                
                if (progressBlock) {
                    progressBlock(numberOfFinishedOperations, [operations count]);
                }
                
                dispatch_group_leave(group);
            });
        };
        
        dispatch_group_enter(group);
        [batchedOperation addDependency:operation];
    }
    
    return [operations arrayByAddingObject:batchedOperation];
}

@end
