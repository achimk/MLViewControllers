//
//  MLCollectionViewDataSource.m
//  ViewControllers
//
//  Created by Joachim Kret on 07.03.2015.
//  Copyright (c) 2015 Joachim Kret. All rights reserved.
//

#import "MLCollectionViewDataSource.h"

#pragma mark - MLCollectionViewDataSource

@interface MLCollectionViewDataSource () <MLResultsControllerObserver>

@property (nonatomic, readwrite, strong) NSMutableArray * batchUpdates;
@property (nonatomic, readwrite, strong) NSMutableArray * insertedSectionIndexes;
@property (nonatomic, readwrite, assign) BOOL showLoadingCell;

@end

#pragma mark -

@implementation MLCollectionViewDataSource

#pragma mark Init / Dealloc

- (instancetype)initWithCollectionView:(UICollectionView *)collectionView resultsController:(id <MLResultsController>)resultsController delegate:(id <MLCollectionViewDataSourceDelegate>)delegate {
    NSParameterAssert(collectionView);
    
    if (self = [super init]) {
        _showLoadingCell = NO;
        _useBatchUpdating = YES;
        _animateCollectionChanges = YES;
        _clearsSelectionOnReloadData = NO;
        _reloadOnCurrentLocaleChange = NO;
        
        __weak typeof(collectionView) weakCollectionView = collectionView;
        _collectionView = weakCollectionView;
        collectionView.dataSource = self;
        

        if (resultsController) {
            _resultsController = resultsController;
            [resultsController addResultsControllerObserver:self];
        }
        
        if (delegate) {
            __weak typeof(delegate) weakDelegate = delegate;
            _delegate = weakDelegate;
            
            [self reloadData];
        }
    }
    
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    _collectionView.dataSource = nil;
}

#pragma mark Accessors

- (void)setResultsController:(id<MLResultsController>)resultsController {
    if (resultsController != _resultsController) {
        if (_resultsController) {
            [_resultsController removeResultsControllerObserver:self];
        }
        
        _resultsController = resultsController;
        
        if (resultsController) {
            [resultsController addResultsControllerObserver:self];
        }
        
        [self reloadData];
    }
}

- (void)setDelegate:(id<MLCollectionViewDataSourceDelegate>)delegate {
    if (delegate) {
        __weak typeof(delegate)weakDelegate = delegate;
        _delegate = weakDelegate;
        
        [self reloadData];
    }
    else {
        _delegate = nil;
    }
}

- (void)setReloadOnCurrentLocaleChange:(BOOL)reloadOnCurrentLocaleChange {
    if (reloadOnCurrentLocaleChange != _reloadOnCurrentLocaleChange) {
        if (_reloadOnCurrentLocaleChange) {
            [[NSNotificationCenter defaultCenter] removeObserver:self
                                                            name:NSCurrentLocaleDidChangeNotification
                                                          object:nil];
        }
        
        _reloadOnCurrentLocaleChange = reloadOnCurrentLocaleChange;
        
        if (reloadOnCurrentLocaleChange) {
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(currentLocaleDidChangeNotification:)
                                                         name:NSCurrentLocaleDidChangeNotification
                                                       object:nil];
        }
    }
}

#pragma mark Reload Data

- (void)reloadData {
    NSAssert2([NSThread isMainThread], @"%@: %@ must be called on main thread!", [self class], NSStringFromSelector(_cmd));
    self.showLoadingCell = self.shouldShowLoadingCell;
    
    if (self.clearsSelectionOnReloadData) {
        [self.collectionView reloadData];
    }
    else {
        NSArray * selectedItems = [[self.collectionView indexPathsForSelectedItems] copy];
        
        [self.collectionView reloadData];
        
        for (NSIndexPath * indexPath in selectedItems) {
            [self.collectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
        }
    }
}

#pragma mark Loading Cell

- (void)updateLoadingCell {
    [self updateLoadingCellAnimated:self.animateCollectionChanges];
}

- (void)updateLoadingCellAnimated:(BOOL)animated {
    if (!animated) {
        [self reloadData];
        return;
    }
    
    BOOL showLoadingCell = self.shouldShowLoadingCell;
    NSIndexPath * indexPath = self.loadingIndexPath;
    
    if (self.showLoadingCell != showLoadingCell) {
        self.showLoadingCell = showLoadingCell;
        
        if (showLoadingCell) {
            [self.collectionView insertSections:[NSIndexSet indexSetWithIndex:indexPath.section]];
        }
        else {
            [self.collectionView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section]];
        }
    }
    else if (showLoadingCell) {
        id cell = [self.collectionView cellForItemAtIndexPath:indexPath];
        
        if (cell) {
            [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
        }
    }
}

- (BOOL)isLoadingSection:(NSUInteger)section {
    return (self.showLoadingCell && (section == self.loadingIndexPath.section));
}

- (BOOL)isLoadingIndexPath:(NSIndexPath *)indexPath {
    if (self.showLoadingCell && indexPath) {
        return [indexPath isEqual:self.loadingIndexPath];
    }
    
    return NO;
}

#pragma mark Notifications

- (void)currentLocaleDidChangeNotification:(NSNotification *)aNotification {
    [self reloadData];
}

#pragma mark UICollectionViewDataSource

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger numberOfSections = self.resultsController.sections.count;
    
    if (indexPath.section == numberOfSections) {
        id <MLCollectionViewLoadingDataSourceDelegate> delegate = (id <MLCollectionViewLoadingDataSourceDelegate>)self.delegate;
        return [delegate collectionView:collectionView loadingCellAtIndexPath:indexPath];
    }
    
    return [self.delegate collectionView:collectionView cellForItemAtIndexPath:indexPath];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    NSUInteger numberOfSections = self.resultsController.sections.count;
    
    if (self.showLoadingCell) {
        numberOfSections++;
    }
    
    return numberOfSections;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSUInteger numberOfSections = self.resultsController.sections.count;
    
    if (section == numberOfSections) {
        return 1;
    }
    
    id <MLResultsSectionInfo> sectionInfo = [self.resultsController.sections objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView * reusableView = nil;
    
    if ([self.delegate respondsToSelector:@selector(collectionView:viewForSupplementaryElementOfKind:atIndexPath:)]) {
        reusableView = [self.delegate collectionView:collectionView viewForSupplementaryElementOfKind:kind atIndexPath:indexPath];
    }
    
    return reusableView;
}

#pragma mark MLResultsControllerObserver

- (void)resultsControllerWillChangeContent:(id<MLResultsController>)resultsController {
    if (self.animateCollectionChanges) {
        if (self.useBatchUpdating) {
            self.batchUpdates = [[NSMutableArray alloc] init];
            self.insertedSectionIndexes = [[NSMutableArray alloc] init];
        }
    }
}

- (void)resultsController:(id<MLResultsController>)resultsController didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(MLResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    if (!self.animateCollectionChanges) {
        return;
    }
    
    if (MLResultsChangeTypeUpdate == type) {
        UICollectionViewCell * cell = [self.collectionView cellForItemAtIndexPath:indexPath];
        
        if (cell) {
            if (self.useBatchUpdating) {
                if ([self.delegate respondsToSelector:@selector(collectionView:updateCell:forObject:atIndexPath:)]) {
                    [self.delegate collectionView:self.collectionView updateCell:cell forObject:anObject atIndexPath:newIndexPath];
                }
                else {
                    [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
                }
            }
            else {
                [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
            }
        }
    }
    else {
        BOOL shouldChangeObject = YES;
        
        if (MLResultsChangeTypeInsert == type) {
            shouldChangeObject = ![self.insertedSectionIndexes containsObject:@(newIndexPath.section)];
        }
        
        if (shouldChangeObject) {
            void (^objectChangeBlock)(void) = ^{
                switch (type) {
                    case MLResultsChangeTypeInsert: {
                        [self.collectionView insertItemsAtIndexPaths:@[newIndexPath]];
                    } break;
                        
                    case MLResultsChangeTypeDelete: {
                        [self.collectionView deleteItemsAtIndexPaths:@[indexPath]];
                    } break;
                        
                    case MLResultsChangeTypeMove: {
                        [self.collectionView moveItemAtIndexPath:indexPath toIndexPath:newIndexPath];
                    } break;
                        
                    case MLResultsChangeTypeUpdate: {
                        // Nothing to do...
                    } break;
                }
            };
            
            if (self.useBatchUpdating && self.batchUpdates) {
                [self.batchUpdates addObject:[objectChangeBlock copy]];
            }
            else {
                objectChangeBlock();
            }
        }
    }
}

- (void)resultsController:(id<MLResultsController>)resultsController didChangeSection:(id<MLResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(MLResultsChangeType)type {
    if (!self.animateCollectionChanges) {
        return;
    }
    
    if (MLResultsChangeTypeInsert == type) {
        [self.insertedSectionIndexes addObject:@(sectionIndex)];
    }
    
    void(^sectionChangeBlock)(void) = ^{
        switch (type) {
            case MLResultsChangeTypeInsert: {
                [self.collectionView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]];
            } break;
                
            case MLResultsChangeTypeDelete: {
                [self.collectionView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]];
            } break;
                
            case MLResultsChangeTypeMove:
            case MLResultsChangeTypeUpdate: {
                // Nothing to do...
            } break;
        }
    };
    
    if (self.useBatchUpdating && self.batchUpdates) {
        [self.batchUpdates addObject:[sectionChangeBlock copy]];
    }
    else {
        sectionChangeBlock();
    }
}

- (void)resultsControllerDidChangeContent:(id<MLResultsController>)resultsController {
    if (self.animateCollectionChanges) {        
        if (self.useBatchUpdating && self.batchUpdates.count) {
            [self.collectionView performBatchUpdates:^{
                [self.batchUpdates enumerateObjectsUsingBlock:^(void (^changeBlock)(void), NSUInteger idx, BOOL *stop) {
                    changeBlock();
                }];
            } completion:^(BOOL finished) {
                self.batchUpdates = nil;
            }];
        }
        
        self.insertedSectionIndexes = nil;
    }
    else {
        [self reloadData];
    }
}

#pragma mark Private Methods

- (NSIndexPath *)loadingIndexPath {
    NSUInteger sections = [self.resultsController.sections count];
    return [NSIndexPath indexPathForRow:0 inSection:sections];
}

- (BOOL)shouldShowLoadingCell {
    if ([self.delegate conformsToProtocol:@protocol(MLCollectionViewLoadingDataSourceDelegate)]) {
        id <MLCollectionViewLoadingDataSourceDelegate> delegate = (id <MLCollectionViewLoadingDataSourceDelegate>)self.delegate;
        NSIndexPath * indexPath = self.loadingIndexPath;
        UICollectionView * collectionView = self.collectionView;
        
        return [delegate collectionView:collectionView shouldShowLoadingCellAtIndexPath:indexPath];
    }
    
    return NO;
}

@end
