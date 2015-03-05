//
//  MLFetchedTableViewController.m
//  ViewControllers
//
//  Created by Joachim Kret on 22.11.2014.
//  Copyright (c) 2014 Joachim Kret. All rights reserved.
//

#import "MLFetchedTableViewController.h"

#pragma mark - MLFetchedTableViewController

@interface MLFetchedTableViewController () {
    BOOL _needsFetch;
    BOOL _updateAnimated;
}

@property (nonatomic, readwrite, strong) NSFetchedResultsController * fetchedResultsController;

@end

#pragma mark -

@implementation MLFetchedTableViewController

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
    METHOD_MUST_BE_OVERRIDDEN;
    return nil;
}

- (NSManagedObjectContext *)managedObjectContext {
    METHOD_MUST_BE_OVERRIDDEN;
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
    METHOD_MUST_BE_OVERRIDDEN;
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

#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.fetchedResultsController.sections count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController.sections objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

#pragma mark NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    switch (self.changeType) {
        case MLChangeTypeUpdate: {
            _updateAnimated = YES;
            [self.tableView beginUpdates];
        } break;
            
        case MLChangeTypeIgnore:
        case MLChangeTypeReload: break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id<NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
    if (!_updateAnimated) {
        return;
    }
    
    UITableViewRowAnimation animation = (self.isViewVisible) ? UITableViewRowAnimationFade : UITableViewRowAnimationAutomatic;
    
    switch (type) {
        case NSFetchedResultsChangeInsert: {
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:animation];
        } break;
            
        case NSFetchedResultsChangeDelete: {
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:animation];
        } break;
 
        case NSFetchedResultsChangeMove:
        case NSFetchedResultsChangeUpdate: break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    if (!_updateAnimated) {
        return;
    }
    
    indexPath = [self viewIndexPathForController:controller fetchedIndexPath:indexPath];
    newIndexPath = [self viewIndexPathForController:controller fetchedIndexPath:newIndexPath];
    UITableViewRowAnimation animation = (self.isViewVisible) ? UITableViewRowAnimationFade : UITableViewRowAnimationAutomatic;
    
    switch (type) {
        case NSFetchedResultsChangeInsert: {
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:animation];
        } break;
            
        case NSFetchedResultsChangeDelete: {
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:animation];
        } break;
            
        case NSFetchedResultsChangeUpdate: {
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:animation];
        } break;
            
        case NSFetchedResultsChangeMove: {
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:animation];
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:animation];
        } break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    if (_updateAnimated) {
        _updateAnimated = NO;
        [self.tableView endUpdates];
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
