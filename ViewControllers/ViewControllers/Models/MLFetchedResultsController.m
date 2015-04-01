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

@interface MLFetchedResultsController () <NSFetchedResultsControllerDelegate>

@property (nonatomic, readonly, strong) NSFetchedResultsController * controller;
@property (nonatomic, readwrite, assign) BOOL shouldDeleteCache;

@end

#pragma mark -

@implementation MLFetchedResultsController

@dynamic predicate;
@dynamic sortDescriptors;

+ (instancetype)controllerWithFetchRequest:(NSFetchRequest *)fetchRequest managedObjectContext:(NSManagedObjectContext *)context sectionNameKeyPath:(NSString *)sectionNameKeyPath cacheName:(NSString *)name {
    return [[[self class] alloc] initWithFetchRequest:fetchRequest
                                 managedObjectContext:context
                                   sectionNameKeyPath:sectionNameKeyPath
                                            cacheName:name];
}

#pragma mark Init

- (instancetype)initWithFetchRequest:(NSFetchRequest *)fetchRequest managedObjectContext:(NSManagedObjectContext *)context sectionNameKeyPath:(NSString *)sectionNameKeyPath cacheName:(NSString *)name {
    NSParameterAssert(fetchRequest);
    NSParameterAssert(context);
    
    if (self = [super init]) {
        _shouldDeleteCache = NO;
        _cacheDeleteRule = MLFetchedCacheDeleteRuleDefault;
        
        _controller = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                          managedObjectContext:context
                                                            sectionNameKeyPath:sectionNameKeyPath
                                                                     cacheName:name];
        _controller.delegate = self;

        NSError * error = nil;
        if (![self performFetch:&error]) {
            NSLog(@"-> Error performing fetch for controller: %@, error : %@", _controller, [error localizedDescription]);
        }
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
}

- (NSPredicate *)predicate {
    return self.controller.fetchRequest.predicate;
}

- (void)setSortDescriptors:(NSArray *)sortDescriptors {
    self.controller.fetchRequest.sortDescriptors = sortDescriptors;
    self.shouldDeleteCache = YES;
}

- (NSArray *)sortDescriptors {
    return self.controller.fetchRequest.sortDescriptors;
}

#pragma mark Fetching

- (BOOL)performFetch:(NSError **)error {
    BOOL clearCache = self.controller.cacheName &&
                    (MLFetchedCacheDeleteRuleAlways == self.cacheDeleteRule ||
                     (MLFetchedCacheDeleteRuleDefault == self.cacheDeleteRule && self.shouldDeleteCache));
    self.shouldDeleteCache = NO;
    
    if (clearCache) {
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
    return [self.controller fetchedObjects];
}

- (NSArray *)sections {
    NSMutableArray * arrayOfSections = [[NSMutableArray alloc] init];
    NSArray * arrayOfFetchedSections = self.controller.sections;
    for (id <NSFetchedResultsSectionInfo> section in arrayOfFetchedSections) {
        id <MLResultsSectionInfo> fetchedSectionInfo = [[MLFetchedResultsSectionInfo alloc] initWithFetchedResultsSectionInfo:section];
        [arrayOfSections addObject:fetchedSectionInfo];
    }
    
    return [NSArray arrayWithArray:arrayOfSections];
}

- (id)objectAtIndexPath:(NSIndexPath *)indexPath {
    return [self.controller objectAtIndexPath:indexPath];
}

- (NSIndexPath *)indexPathForObject:(id)object {
    return [self.controller indexPathForObject:object];
}

#pragma mark NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    for (id <MLResultsControllerObserver> observer in self.arrayOfObservers) {
        [observer resultsControllerWillChangeContent:self];
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    for (id <MLResultsControllerObserver> observer in self.arrayOfObservers) {
        if ([observer respondsToSelector:@selector(resultsController:didChangeObject:atIndexPath:forChangeType:newIndexPath:)]) {
            [observer resultsController:self
                        didChangeObject:anObject
                            atIndexPath:indexPath
                          forChangeType:(MLResultsChangeType)type
                           newIndexPath:newIndexPath];
        }
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id<NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    id <MLResultsSectionInfo> fetchedSectionInfo = [[MLFetchedResultsSectionInfo alloc] initWithFetchedResultsSectionInfo:sectionInfo];
    
    for (id <MLResultsControllerObserver> observer in self.arrayOfObservers) {
        if ([observer respondsToSelector:@selector(resultsController:didChangeSection:atIndex:forChangeType:)]) {
            [observer resultsController:self
                       didChangeSection:fetchedSectionInfo
                                atIndex:sectionIndex
                          forChangeType:(MLResultsChangeType)type];
        }
    }

}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    for (id <MLResultsControllerObserver> observer in self.arrayOfObservers) {
        [observer resultsControllerDidChangeContent:self];
    }
}

@end
