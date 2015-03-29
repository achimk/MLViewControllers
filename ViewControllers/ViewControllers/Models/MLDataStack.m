//
//  MLDataStack.m
//  ViewControllers
//
//  Created by Joachim Kret on 29.03.2015.
//  Copyright (c) 2015 Joachim Kret. All rights reserved.
//

#import "MLDataStack.h"

@implementation MLDataStack

@synthesize savingContext = _savingContext;
@synthesize mainContext = _mainContext;

#pragma mark Load Stack

- (void)loadStack {
    [super loadStack];
    
    [self savingContext];
    [self mainContext];
}

#pragma mark Accessors

- (NSManagedObjectContext *)managedObjectContext {
    NSDictionary * threadDictionary = [[NSThread currentThread] threadDictionary];
    NSManagedObjectContext * threadContext = threadDictionary[MLActiveRecordManagedObjectContextKey];

    return (threadContext) ?: self.mainContext;
}

- (NSManagedObjectContext *)savingContext {
    if (!_savingContext) {
        _savingContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        _savingContext.persistentStoreCoordinator = self.persistentStoreCoordinator;
    }
    
    return _savingContext;
}

- (NSManagedObjectContext *)mainContext {
    if (!_mainContext) {
        _mainContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        _mainContext.parentContext = self.savingContext;
    }
    
    return _mainContext;
}

- (NSManagedObjectContext *)stackSavingContext {
    return self.mainContext;
}

@end
