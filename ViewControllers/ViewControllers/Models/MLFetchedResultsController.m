//
//  MLFetchedResultsController.m
//  ViewControllers
//
//  Created by Joachim Kret on 08.03.2015.
//  Copyright (c) 2015 Joachim Kret. All rights reserved.
//

#import "MLFetchedResultsController.h"

#pragma mark - MLFetchedResultsSectionInfo

@interface MLFetchedResultsSectionInfo : NSObject <MLResultsSectionInfo>

@property (nonatomic, readonly, strong) id <NSFetchedResultsSectionInfo> section;

- (instancetype)initWithFetchedResultsSectionInfo:(id <NSFetchedResultsSectionInfo>)section;

@end

#pragma mark -

@implementation MLFetchedResultsSectionInfo

@dynamic name;
@dynamic indexTitle;
@dynamic numberOfObjects;
@dynamic objects;

#pragma mark Init

- (instancetype)initWithFetchedResultsSectionInfo:(id <NSFetchedResultsSectionInfo>)section {
    NSParameterAssert(section);
    
    if (self = [super init]) {
        _section = section;
    }
    
    return self;
}

#pragma mark Accessors

- (NSString *)name {
    return self.section.name;
}

- (NSString *)indexTitle {
    return self.section.indexTitle;
}

- (NSUInteger)numberOfObjects {
    return self.section.numberOfObjects;
}

- (NSArray *)objects {
    return self.section.objects;
}

@end

#pragma mark - MLFetchedResultsController

@interface MLFetchedResultsController () <NSFetchedResultsControllerDelegate> {
    BOOL _needsFetch;
}

@property (nonatomic, readonly, strong) NSFetchedResultsController * controller;
@property (nonatomic, readwrite, assign) BOOL shouldDeleteCache;

@end

#pragma mark -

@implementation MLFetchedResultsController

@dynamic predicate;
@dynamic sortDescriptors;
@dynamic allObjects;
@dynamic sections;

#pragma mark Init

- (instancetype)init {
    METHOD_USE_DESIGNATED_INIT;
    return nil;
}

- (instancetype)initWithFetchRequest:(NSFetchRequest *)fetchRequest managedObjectContext:(NSManagedObjectContext *)context sectionNameKeyPath:(NSString *)sectionNameKeyPath cacheName:(NSString *)name {
    NSParameterAssert(fetchRequest);
    NSParameterAssert(context);
    
    if (self = [super init]) {
        _controller = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                          managedObjectContext:context
                                                            sectionNameKeyPath:sectionNameKeyPath
                                                                     cacheName:name];
        _controller.delegate = self;
        _needsFetch = YES;
        _shouldDeleteCache = NO;
        _cacheDeleteRule = MLFetchedCacheDeleteRuleDefault;
    }
    
    return self;
}

- (void)dealloc {
    self.controller.delegate = nil;
}

#pragma mark Accessors

- (void)setPredicate:(NSPredicate *)predicate {
    self.controller.fetchRequest.predicate = predicate;
    self.shouldDeleteCache = YES;
    [self setNeedsFetch];
}

- (NSPredicate *)predicate {
    return self.controller.fetchRequest.predicate;
}

- (void)setSortDescriptors:(NSArray *)sortDescriptors {
    self.controller.fetchRequest.sortDescriptors = sortDescriptors;
    self.shouldDeleteCache = YES;
    [self setNeedsFetch];
}

- (NSArray *)sortDescriptors {
    return self.controller.fetchRequest.sortDescriptors;
}

- (void)setNeedsFetch {
    _needsFetch = YES;
}

- (BOOL)needsFetch {
    return _needsFetch;
}

#pragma mark Fetching

- (BOOL)fetchIfNeeded:(NSError **)error {
    return ([self needsFetch]) ? [self performFetch:error] : NO;
}

- (BOOL)performFetch:(NSError **)error {
    _needsFetch = NO;
    
    if (self.controller.cacheName && (self.shouldDeleteCache || MLFetchedCacheDeleteRuleAlways == self.cacheDeleteRule)) {
        self.shouldDeleteCache = NO;
        [NSFetchedResultsController deleteCacheWithName:self.controller.cacheName];
    }
    
    NSError * fetchError = nil;
    BOOL isFetched = [self.controller performFetch:&fetchError];
    NSAssert2(isFetched, @"Unresolved NSFetchedResultsController error: %@, %@", fetchError, fetchError.userInfo);
    
    if (error) {
        *error = fetchError;
    }
    
    return isFetched;
}

#pragma mark MLResultsController

- (NSArray *)allObjects {
#warning Implement
    return nil;
}

- (NSArray *)sections {
#warning Implement
    return nil;
}

- (id)objectAtIndexPath:(NSIndexPath *)indexPath {
#warning Implement
    return nil;
}

- (NSIndexPath *)indexPathForObject:(id)object {
#warning Implement
    return nil;
}

- (void)addResultsControllerObserver:(id <MLResultsControllerObserver>)observer {
#warning Implement
}

- (void)removeResultsControllerObserver:(id <MLResultsControllerObserver>)observer {
#warning Implement
}

#pragma mark NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {

}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {

}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id<NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {

}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {

}

@end
