//
//  MLFetchedCollectionViewController.m
//  ViewControllers
//
//  Created by Joachim Kret on 22.11.2014.
//  Copyright (c) 2014 Joachim Kret. All rights reserved.
//

#import "MLFetchedCollectionViewController.h"

#pragma mark - MLFetchedCollectionViewController

@interface MLFetchedCollectionViewController () {
    BOOL _needsFetch;
    BOOL _updateAnimated;
}

@property (nonatomic, readwrite, strong) NSFetchedResultsController * fetchedResultsController;
@property (nonatomic, readonly, strong) NSMutableArray * sectionChanges;
@property (nonatomic, readonly, strong) NSMutableArray * objectChanges;

@end

#pragma mark -

@implementation MLFetchedCollectionViewController

@synthesize fetchedResultsController = _fetchedResultsController;
@dynamic empty;

+ (Class)defaultFetchedResultsControllerClass {
    return [NSFetchedResultsController class];
}

#pragma mark Init

- (id)initWithFetchedResultsController:(NSFetchedResultsController *)fetchedResultsController {
    if (self = [self initWithNibName:nil bundle:nil]) {
        self.fetchedResultsController = fetchedResultsController;
    }
    
    return self;
}

- (void)finishInitialize {
    [super finishInitialize];
    
    _needsFetch = YES;
    _updateAnimated = NO;
    _changeType = MLChangeTypeUpdate;
    _sectionChanges = [NSMutableArray new];
    _objectChanges = [NSMutableArray new];
}

#pragma mark View

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self fetchIfNeeded];
}

- (void)viewWillAppear:(BOOL)animated {
    [self fetchIfNeeded];
    
    [super viewWillAppear:animated];
}

#pragma mark Accessors

- (void)setFetchedResultsController:(NSFetchedResultsController *)fetchedResultsController {
    if (fetchedResultsController != _fetchedResultsController) {
        if (_fetchedResultsController) {
            _fetchedResultsController.delegate = nil;
        }
        
        _fetchedResultsController = fetchedResultsController;
        
        if (fetchedResultsController) {
            fetchedResultsController.delegate = self;
        }
    }
}

- (NSFetchedResultsController *)fetchedResultsController {
    if (!_fetchedResultsController) {
        [self willCreateFetchedResultsController];
        
        NSFetchedResultsController * fetchedResultsController = [[[[self class] defaultFetchedResultsControllerClass] alloc] initWithFetchRequest:self.fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:self.sectionNameKeyPath cacheName:self.cacheName];
        self.fetchedResultsController = fetchedResultsController;
        
        [self didCreateFetchedResultsController];
    }
    
    return _fetchedResultsController;
}

- (BOOL)isEmpty {
    [self fetchIfNeeded];
    return (0 == self.fetchedResultsController.fetchedObjects.count);
}

#pragma mark Configure NSFetchedResutlsController

- (NSString *)entityName {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in subclass.", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
    return nil;
}

- (NSManagedObjectContext *)managedObjectContext {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in subclass.", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
    return nil;
}

- (NSFetchRequest *)fetchRequest {
    NSFetchRequest * fetchRequest = [NSFetchRequest new];
    fetchRequest.entity = [NSEntityDescription entityForName:self.entityName
                                      inManagedObjectContext:self.managedObjectContext];
    fetchRequest.sortDescriptors = self.sortDescriptors;
    fetchRequest.predicate = self.predicate;
    fetchRequest.fetchBatchSize = MLFetchedResultsBatchSize;
    fetchRequest.returnsObjectsAsFaults = NO;
    
    return fetchRequest;
}

- (NSArray *)sortDescriptors {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in subclass.", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
    return nil;
}

- (NSPredicate *)predicate {
    return nil;
}

- (NSString *)sectionNameKeyPath {
    return nil;
}

- (NSString *)cacheName {
    return nil;
}

- (void)willCreateFetchedResultsController {
    //Subclasses may override this method
}

- (void)didCreateFetchedResultsController {
    //Subclasses may override this method
}

- (NSIndexPath *)viewIndexPathForFetchedIndexPath:(NSIndexPath *)fetchedIndexPath {
    return [self viewIndexPathForController:self.fetchedResultsController fetchedIndexPath:fetchedIndexPath];
}

- (NSIndexPath *)viewIndexPathForController:(NSFetchedResultsController *)controller fetchedIndexPath:(NSIndexPath *)fetchedIndexPath {
    NSParameterAssert(controller);
    return fetchedIndexPath;
}

- (NSIndexPath *)fetchedIndexPathForViewIndexPath:(NSIndexPath *)viewIndexPath {
    return [self fetchedIndexPathForController:self.fetchedResultsController viewIndexPath:viewIndexPath];
}

- (NSIndexPath *)fetchedIndexPathForController:(NSFetchedResultsController *)controller viewIndexPath:(NSIndexPath *)viewIndexPath {
    NSParameterAssert(controller);
    return viewIndexPath;
}

- (id)objectForViewIndexPath:(NSIndexPath *)viewIndexPath {
    return [self objectForController:self.fetchedResultsController viewIndexPath:viewIndexPath];
}

- (id)objectForController:(NSFetchedResultsController *)controller viewIndexPath:(NSIndexPath *)viewIndexPath {
    NSParameterAssert(controller);
    return [controller objectAtIndexPath:[self fetchedIndexPathForController:controller viewIndexPath:viewIndexPath]];
}

#pragma mark Fetch Data

- (void)setNeedsFetch {
    _needsFetch = YES;
}

- (BOOL)needsFetch {
    return _needsFetch;
}

- (void)fetchIfNeeded {
    if (self.needsFetch) {
        [self performFetch];
    }
}

- (void)fetchIfVisible {
    if (self.isViewVisible) {
        [self performFetch];
    }
}

- (void)performFetch {
    NSAssert2([NSThread isMainThread], @"%@: %@ must be called on main thread", [self class], NSStringFromSelector(_cmd));
    _needsFetch = NO;
    
    if (self.fetchedResultsController) {
        if (self.cacheName) {
            [NSFetchedResultsController deleteCacheWithName:self.cacheName];
        }
        
        self.fetchedResultsController.fetchRequest.predicate = self.predicate;
        self.fetchedResultsController.fetchRequest.sortDescriptors = self.sortDescriptors;
        NSError * fetchError = nil;
        
        if (![self.fetchedResultsController performFetch:&fetchError]) {
            NSAssert2(NO, @"Unresolved fetched results controller error: %@, %@", fetchError, fetchError.userInfo);
        }
        
        if (self.isViewVisible) {
            [self reloadData];
        }
        else {
            [self setNeedsReload];
        }
        
        self.showsBackgroundView = self.isEmpty;
    }
}

#pragma mark UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return [self.fetchedResultsController.sections count];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController.sections objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

#pragma mark NSFetchedResultsControllerDelegate

/*
 *  implementation from: https://github.com/iceesj/MR_PSUICollectionViewController/blob/master/testPST/ViewController.m
 */

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    switch (self.changeType) {
        case MLChangeTypeUpdate: {
            _updateAnimated = YES;
            break;
        }
        case MLChangeTypeIgnore:
        case MLChangeTypeReload:
        default: {
            break;
        }
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id<NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
    if (!_updateAnimated) {
        return;
    }
    
    NSMutableDictionary * changes = [NSMutableDictionary dictionary];
    
    switch (type) {
        case NSFetchedResultsChangeInsert: {
            changes[@(NSFetchedResultsChangeInsert)] = @(sectionIndex);
            break;
        }
        case NSFetchedResultsChangeDelete: {
            changes[@(NSFetchedResultsChangeDelete)] = @(sectionIndex);
            break;
        }
        case NSFetchedResultsChangeUpdate: {
            changes[@(NSFetchedResultsChangeUpdate)] = @(sectionIndex);
            break;
        }
        default: {
            break;
        }
    }
    
    [self.sectionChanges addObject:changes];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    if (!_updateAnimated) {
        return;
    }
    
    indexPath = [self viewIndexPathForController:controller fetchedIndexPath:indexPath];
    newIndexPath = [self viewIndexPathForController:controller fetchedIndexPath:newIndexPath];
    NSMutableDictionary * changes = [NSMutableDictionary dictionary];
    
    switch (type) {
        case NSFetchedResultsChangeInsert: {
            changes[@(NSFetchedResultsChangeInsert)] = newIndexPath;
            break;
        }
        case NSFetchedResultsChangeDelete: {
            changes[@(NSFetchedResultsChangeDelete)] = indexPath;
            break;
        }
        case NSFetchedResultsChangeUpdate: {
            changes[@(NSFetchedResultsChangeUpdate)] = indexPath;
            break;
        }
        case NSFetchedResultsChangeMove: {
            changes[@(NSFetchedResultsChangeMove)] = @[indexPath, newIndexPath];
            break;
        }
        default: {
            break;
        }
    }
    
    [self.objectChanges addObject:changes];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    if (_updateAnimated) {
        _updateAnimated = NO;
        
        if (0 < self.sectionChanges.count) {
            [self.collectionView performBatchUpdates:^{
                for (NSDictionary * change in self.sectionChanges) {
                    [change enumerateKeysAndObjectsUsingBlock:^(NSNumber * key, id obj, BOOL * stop) {
                        NSFetchedResultsChangeType type = [key unsignedIntegerValue];
                        
                        switch (type) {
                            case NSFetchedResultsChangeInsert: {
                                [self.collectionView insertSections:[NSIndexSet indexSetWithIndex:[obj unsignedIntegerValue]]];
                                break;
                            }
                            case NSFetchedResultsChangeDelete: {
                                [self.collectionView deleteSections:[NSIndexSet indexSetWithIndex:[obj unsignedIntegerValue]]];
                                break;
                            }
                            case NSFetchedResultsChangeUpdate: {
                                [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:[obj unsignedIntegerValue]]];
                                break;
                            }
                            default: {
                                break;
                            }
                        }
                    }];
                }
            } completion:NULL];
        }
        
        if (0 < self.objectChanges.count && 0 == self.sectionChanges.count) {
            [self.collectionView performBatchUpdates:^{
                for (NSDictionary * change in self.objectChanges) {
                    [change enumerateKeysAndObjectsUsingBlock:^(NSNumber * key, id obj, BOOL * stop) {
                        NSFetchedResultsChangeType type = [key unsignedIntegerValue];
                        
                        switch (type) {
                            case NSFetchedResultsChangeInsert: {
                                [self.collectionView insertItemsAtIndexPaths:@[obj]];
                                break;
                            }
                            case NSFetchedResultsChangeDelete: {
                                [self.collectionView deleteItemsAtIndexPaths:@[obj]];
                                break;
                            }
                            case NSFetchedResultsChangeUpdate: {
                                [self.collectionView reloadItemsAtIndexPaths:@[obj]];
                                break;
                            }
                            case NSFetchedResultsChangeMove: {
                                [self.collectionView moveItemAtIndexPath:obj[0] toIndexPath:obj[1]];
                                break;
                            }
                            default: {
                                break;
                            }
                        }
                    }];
                }
            } completion:NULL];
        }
        
        [self.sectionChanges removeAllObjects];
        [self.objectChanges removeAllObjects];
    }
    else if (MLChangeTypeReload == self.changeType) {
        if (self.isViewVisible) {
            [self reloadData];
        }
        else {
            [self setNeedsReload];
        }
    }
    else {
        [self setNeedsReload];
    }
    
    self.showsBackgroundView = self.isEmpty;
}

@end
