//
//  MLOperationTestCase.m
//  ViewControllers
//
//  Created by Joachim Kret on 10.04.2015.
//  Copyright (c) 2015 Joachim Kret. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "MLOperation.h"
#import "MLAsynchronousOperation.h"
#import "MLBlockOperation.h"

#define NUMBER_OF_OPERATIONS        10
#define OPERATION_EXECUTION_TIME    1   // In seconds

#pragma mark - MLTestOperation

@interface MLTestOperation : MLOperation

@property (nonatomic, readonly, assign) NSUInteger executionCounter;
@property (nonatomic, readonly, assign) NSUInteger cancellationCounter;
@property (nonatomic, readwrite, assign) BOOL shouldCancel;

@end

@implementation MLTestOperation

#pragma mark Subclassing Methods

- (void)onExecute {
    _executionCounter++;
    
    if (self.shouldCancel) {
        [self cancel];
    }
    else {
        sleep(OPERATION_EXECUTION_TIME);
    }
}

- (void)onCancel {
    _cancellationCounter++;
}

@end

#pragma mark - MLBlockOperation

@interface MLTestAsynchronousOperation : MLAsynchronousOperation

@property (nonatomic, readonly, assign) NSUInteger executionCounter;
@property (nonatomic, readonly, assign) NSUInteger cancellationCounter;
@property (nonatomic, readwrite, assign) BOOL shouldCancel;

@end

@implementation MLTestAsynchronousOperation

#pragma mark Subclassing Methods

- (void)onExecute {
    _executionCounter++;
    
    if (self.shouldCancel) {
        [self cancel];
    }
    else {
        sleep(OPERATION_EXECUTION_TIME);
    }
}

- (void)onCancel {
    _cancellationCounter++;
}

@end

#pragma mark - MLBlockOperation

@interface MLTestBlockOperation : MLBlockOperation

@property (nonatomic, readonly, assign) NSUInteger executionCounter;
@property (nonatomic, readonly, assign) NSUInteger cancellationCounter;
@property (nonatomic, readwrite, assign) BOOL shouldCancel;

@end

@implementation MLTestBlockOperation

#pragma mark Subclassing Methods

- (void)onExecute {
    _executionCounter++;
    
    if (self.shouldCancel) {
        [self cancel];
    }
    else {
        sleep(OPERATION_EXECUTION_TIME);
    }
}

- (void)onCancel {
    _cancellationCounter++;
}

@end

#pragma mark - MLOperationTestCase

@interface MLOperationTestCase : XCTestCase

@end

#pragma mark -

@implementation MLOperationTestCase

#pragma mark Setup

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

#pragma mark Synchronous Operation Tests

- (void)testEnqueueOperations {
    NSArray * operations = [self createOperations];
    NSOperationQueue * queue = [self createConcurrentOperationQueue];
    [queue addOperations:operations waitUntilFinished:YES];
    
    for (MLTestOperation * operation in operations) {
        XCTAssertFalse(operation.isCancelled);
        XCTAssertTrue(operation.isFinished);
        XCTAssertEqual(operation.cancellationCounter, 0);
        XCTAssertEqual(operation.executionCounter, 1);
    }
}

- (void)testCancelOperations {
    NSArray * operations = [self createOperations];
    [self cancelOperations:operations];
    NSOperationQueue * queue = [self createConcurrentOperationQueue];
    [queue addOperations:operations waitUntilFinished:YES];
    
    for (MLTestOperation * operation in operations) {
        XCTAssertTrue(operation.isCancelled);
        XCTAssertTrue(operation.isFinished);
        XCTAssertEqual(operation.cancellationCounter, 0);
        XCTAssertEqual(operation.executionCounter, 0);
    }
}

- (void)testMultipleCancelOperations {
    NSArray * operations = [self createOperations];
    [self cancelOperations:operations];
    NSOperationQueue * queue = [self createConcurrentOperationQueue];
    [queue addOperations:operations waitUntilFinished:YES];
    [self cancelOperations:operations];
    
    for (MLTestOperation * operation in operations) {
        XCTAssertTrue(operation.isCancelled);
        XCTAssertTrue(operation.isFinished);
        XCTAssertEqual(operation.cancellationCounter, 0);
        XCTAssertEqual(operation.executionCounter, 0);
    }
}

- (void)testExecutionCancelOperations {
    NSArray * operations = [self createOperations];
    [self cancelOperationsInExecution:operations];
    NSOperationQueue * queue = [self createConcurrentOperationQueue];
    [queue addOperations:operations waitUntilFinished:YES];
    
    for (MLTestOperation * operation in operations) {
        XCTAssertTrue(operation.isCancelled);
        XCTAssertTrue(operation.isFinished);
        XCTAssertEqual(operation.cancellationCounter, 1);
        XCTAssertEqual(operation.executionCounter, 1);
    }
}

#pragma mark Asynchronous Operation Tests

- (void)testEnqueueAsynchronousOperations {
    NSArray * operations = [self createAsynchronousOperations];
    NSOperationQueue * queue = [self createConcurrentOperationQueue];
    [queue addOperations:operations waitUntilFinished:YES];
    
    for (MLTestAsynchronousOperation * operation in operations) {
        XCTAssertFalse(operation.isCancelled);
        XCTAssertTrue(operation.isFinished);
        XCTAssertEqual(operation.cancellationCounter, 0);
        XCTAssertEqual(operation.executionCounter, 1);
    }
}

- (void)testCancelAsynchronousOperations {
    NSArray * operations = [self createAsynchronousOperations];
    [self cancelOperations:operations];
    NSOperationQueue * queue = [self createConcurrentOperationQueue];
    [queue addOperations:operations waitUntilFinished:YES];
    
    for (MLTestAsynchronousOperation * operation in operations) {
        XCTAssertTrue(operation.isCancelled);
        XCTAssertTrue(operation.isFinished);
        XCTAssertEqual(operation.cancellationCounter, 1);
        XCTAssertEqual(operation.executionCounter, 0);
    }
}

- (void)testMultipleCancelAsynchronousOperations {
    NSArray * operations = [self createAsynchronousOperations];
    [self cancelOperations:operations];
    NSOperationQueue * queue = [self createConcurrentOperationQueue];
    [queue addOperations:operations waitUntilFinished:YES];
    [self cancelOperations:operations];
    
    for (MLTestAsynchronousOperation * operation in operations) {
        XCTAssertTrue(operation.isCancelled);
        XCTAssertTrue(operation.isFinished);
        XCTAssertEqual(operation.cancellationCounter, 1);
        XCTAssertEqual(operation.executionCounter, 0);
    }
}

- (void)testExecutionCancelAsynchronousOperations {
    NSArray * operations = [self createAsynchronousOperations];
    [self cancelOperationsInExecution:operations];
    NSOperationQueue * queue = [self createConcurrentOperationQueue];
    [queue addOperations:operations waitUntilFinished:YES];
    
    for (MLTestAsynchronousOperation * operation in operations) {
        XCTAssertTrue(operation.isCancelled);
        XCTAssertTrue(operation.isFinished);
        XCTAssertEqual(operation.cancellationCounter, 1);
        XCTAssertEqual(operation.executionCounter, 1);
    }
}

#pragma mark Block Operation Tests

- (void)testEnqueueBlockOperations {
    NSArray * operations = [self createBlockOperations];
    NSOperationQueue * queue = [self createConcurrentOperationQueue];
    [queue addOperations:operations waitUntilFinished:YES];
    
    for (MLTestBlockOperation * operation in operations) {
        XCTAssertFalse(operation.isCancelled);
        XCTAssertTrue(operation.isFinished);
        XCTAssertEqual(operation.cancellationCounter, 0);
        XCTAssertEqual(operation.executionCounter, 1);
    }
}

- (void)testCancelBlockOperations {
    NSArray * operations = [self createBlockOperations];
    [self cancelOperations:operations];
    NSOperationQueue * queue = [self createConcurrentOperationQueue];
    [queue addOperations:operations waitUntilFinished:YES];
    
    for (MLTestBlockOperation * operation in operations) {
        XCTAssertTrue(operation.isCancelled);
        XCTAssertTrue(operation.isFinished);
        XCTAssertEqual(operation.cancellationCounter, 1);
        XCTAssertEqual(operation.executionCounter, 0);
    }
}

- (void)testMultipleCancelBlockOperations {
    NSArray * operations = [self createBlockOperations];
    [self cancelOperations:operations];
    NSOperationQueue * queue = [self createConcurrentOperationQueue];
    [queue addOperations:operations waitUntilFinished:YES];
    [self cancelOperations:operations];
    
    for (MLTestBlockOperation * operation in operations) {
        XCTAssertTrue(operation.isCancelled);
        XCTAssertTrue(operation.isFinished);
        XCTAssertEqual(operation.cancellationCounter, 1);
        XCTAssertEqual(operation.executionCounter, 0);
    }
}

- (void)testExecutionCancelBlockOperations {
    NSArray * operations = [self createBlockOperations];
    [self cancelOperationsInExecution:operations];
    NSOperationQueue * queue = [self createConcurrentOperationQueue];
    [queue addOperations:operations waitUntilFinished:YES];
    
    for (MLTestBlockOperation * operation in operations) {
        XCTAssertTrue(operation.isCancelled);
        XCTAssertTrue(operation.isFinished);
        XCTAssertEqual(operation.cancellationCounter, 1);
        XCTAssertEqual(operation.executionCounter, 1);
    }
}

#pragma mark Private Methods

- (NSOperationQueue *)createSerialOperationQueue {
    NSOperationQueue * operationQueue = [[NSOperationQueue alloc] init];
    operationQueue.maxConcurrentOperationCount = 1;
    return operationQueue;
}

- (NSOperationQueue *)createConcurrentOperationQueue {
    NSOperationQueue * operationQueue = [[NSOperationQueue alloc] init];
    operationQueue.maxConcurrentOperationCount = NSOperationQueueDefaultMaxConcurrentOperationCount;
    return operationQueue;
}

- (NSArray *)createOperations {
    NSMutableArray * arrayOfOperations = [[NSMutableArray alloc] init];
    for (NSUInteger i = 0; i < NUMBER_OF_OPERATIONS; i++) {
        MLTestOperation * operation = [[MLTestOperation alloc] initWithIdentifier:@(i).description];
        [arrayOfOperations addObject:operation];
    }
    
    return [NSArray arrayWithArray:arrayOfOperations];
}

- (NSArray *)createAsynchronousOperations {
    NSMutableArray * arrayOfOperations = [[NSMutableArray alloc] init];
    for (NSUInteger i = 0; i < NUMBER_OF_OPERATIONS; i++) {
        MLTestAsynchronousOperation * operation = [[MLTestAsynchronousOperation alloc] initWithIdentifier:@(i).description];
        [arrayOfOperations addObject:operation];
    }
    
    return [NSArray arrayWithArray:arrayOfOperations];
}

- (NSArray *)createBlockOperations {
    NSMutableArray * arrayOfOperations = [[NSMutableArray alloc] init];
    for (NSUInteger i = 0; i < NUMBER_OF_OPERATIONS; i++) {
        MLTestBlockOperation * operation = [[MLTestBlockOperation alloc] initWithIdentifier:@(i).description];
        __weak typeof(operation)weakOperation = operation;
        [operation addExecutionBlock:^{
            sleep(OPERATION_EXECUTION_TIME);
            XCTAssertNotNil(weakOperation);
            XCTAssertFalse(weakOperation.isCancelled);
        }];
        [arrayOfOperations addObject:operation];
    }
    
    return [NSArray arrayWithArray:arrayOfOperations];
}

- (void)cancelOperations:(NSArray *)arrayOfOperations {
    [self cancelOperations:arrayOfOperations inExecution:NO];
}

- (void)cancelOperationsInExecution:(NSArray *)arrayOfOperations {
    [self cancelOperations:arrayOfOperations inExecution:YES];
}

- (void)cancelOperations:(NSArray *)arrayOfOperations inExecution:(BOOL)flag {
    for (NSOperation * operation in arrayOfOperations) {
        if (flag) {
            [(id)operation setShouldCancel:YES];
        }
        else {
            [operation cancel];
        }
    }
}

- (void)logOperations:(NSArray *)arrayOfOperations {
    for (NSOperation * operation in arrayOfOperations) {
        NSLog(@"-> %@", [operation description]);
    }
}

@end
