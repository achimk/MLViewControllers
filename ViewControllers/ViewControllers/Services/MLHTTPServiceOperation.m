//
//  MLHTTPServiceOperation.m
//  ViewControllers
//
//  Created by Joachim Kret on 10.04.2015.
//  Copyright (c) 2015 Joachim Kret. All rights reserved.
//

#import "MLHTTPServiceOperation.h"

#pragma mark - MLOperation

@interface MLOperation ()

@property (nonatomic, readonly, strong) NSRecursiveLock * lock;
@property (nonatomic, readwrite, assign) MLOperationState state;
@property (nonatomic, readwrite, strong) NSError * error;

@end

#pragma mark - MLHTTPServiceOperation

@interface MLHTTPServiceOperation ()

@end

#pragma mark -

@implementation MLHTTPServiceOperation

#pragma mark Init

- (instancetype)initWithHTTPOperation:(AFHTTPRequestOperation *)operation query:(id <MLServiceQuery>)query {
    return [self initWithIdentifier:nil HTTPRequestOperation:operation query:query];
}

- (instancetype)initWithIdentifier:(NSString *)identifier HTTPRequestOperation:(AFHTTPRequestOperation *)operation query:(id <MLServiceQuery>)query {
    NSParameterAssert(operation);
    NSParameterAssert(!operation.isExecuting && !operation.isFinished);
    NSParameterAssert(query);
    
    if (self = [super initWithIdentifier:identifier]) {
        _httpRequestOperation = operation;
        _query = query;
    }
    
    return self;
}

#pragma mark Subclass Methods

- (void)start {
    [self.lock lock];
    self.state = MLOperationStateExecuting;
    
    if (!self.isCancelled) {
        [self onExecute];
    }
    
    if (self.isCancelled) {
        [self onCancel];
        self.state = MLOperationStateFinished;
    }
    
    [self.lock unlock];
}

- (void)onExecute {
    __weak typeof(self)weakSelf = self;
    [self.httpRequestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        __strong typeof(weakSelf)strongSelf = weakSelf;
        [strongSelf requestOperationSuccess:responseObject];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        __strong typeof(weakSelf)strongSelf = weakSelf;
        [strongSelf requestOperationFailure:error];
    }];
    [self.httpRequestOperation start];
}

- (void)onCancel {
    [self.httpRequestOperation cancel];
}

#pragma mark HTTP Request Operation Callbacks

- (void)requestOperationSuccess:(id)responseObject {

}

- (void)requestOperationFailure:(NSError *)error {
    if (self.isCancelled) {
        return;
    }
    
    self.error = error;
    self.state = MLOperationStateFinished;
}

#pragma mark Completion Blocks

- (void)setCompletionBlockWithSuccess:(void (^)(MLOperation *))success failure:(void (^)(MLOperation *))failure {
    __weak typeof(self)weakSelf = self;
    [self setCompletionBlock:^{
        __strong typeof(weakSelf)strongSelf = weakSelf;
        
        if (strongSelf.isCancelled) {
            return;
        }
        
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

@end
