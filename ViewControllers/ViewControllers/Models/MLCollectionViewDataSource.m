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

@property (nonatomic, readwrite, strong) NSMutableArray *batchUpdates;
@property (nonatomic, readwrite, strong) NSMutableArray *insertedSectionIndexes;
@property (nonatomic, readwrite, assign) BOOL showLoadingCell;
@property (nonatomic, readwrite, assign) BOOL reloadAfterAnimation;

@end

#pragma mark -

@implementation MLCollectionViewDataSource

#pragma mark Init

- (instancetype)init {
    METHOD_USE_DESIGNATED_INIT;
    return nil;
}

- (instancetype)initWithCollectionView:(UICollectionView *)collectionView resultsController:(id <MLResultsController>)resultsController delegate:(id <MLCollectionViewDataSourceDelegate>)delegate {
    NSParameterAssert(collectionView);
    
    if (self = [super init]) {
        _showLoadingCell = NO;
        _useBatchUpdating = YES;
        _reloadAfterAnimation = NO;
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
    self.collectionView.dataSource = nil;
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

#pragma mark Notifications

- (void)currentLocaleDidChangeNotification:(NSNotification *)aNotification {
    [self reloadData];
}

#pragma mark UICollectionViewDataSource

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.showLoadingCell && [indexPath isEqual:self.loadingIndexPath]) {
        id <MLCollectionViewLoadingDataSourceDelegate> delegate = (id <MLCollectionViewLoadingDataSourceDelegate>) self.delegate;
        return [delegate collectionView:collectionView loadingCellAtIndexPath:indexPath];
    }
    
    id object = [self.resultsController objectAtIndexPath:indexPath];
    return [self.delegate collectionView:self.collectionView cellForObject:object atIndexPath:indexPath];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return [self.resultsController.sections count];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    id <MLResultsSectionInfo> sectionInfo = [self.resultsController.sections objectAtIndex:section];
    NSUInteger numberOfObjects = [sectionInfo numberOfObjects];
    
    if (self.showLoadingCell) {
        NSUInteger sections = [self.resultsController.sections count];
        
        if (section == (sections - 1)) {
            numberOfObjects++;
        }
    }
    
    return numberOfObjects;
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
            self.reloadAfterAnimation = NO;
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
                    self.reloadAfterAnimation = YES;
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
    if (self.animateCollectionChanges && self.collectionView.window) {
        if (self.useBatchUpdating) {
            if (self.batchUpdates.count) {
                [self.collectionView performBatchUpdates:^{
                    [self.batchUpdates enumerateObjectsUsingBlock:^(void (^changeBlock)(void), NSUInteger idx, BOOL *stop) {
                        changeBlock();
                    }];
                } completion:^(BOOL finished) {
                    if (self.reloadAfterAnimation) {
                        self.reloadAfterAnimation = NO;
                        
                        [self reloadData];
                    }
                    
                    self.batchUpdates = nil;
                }];
            }
            
            self.insertedSectionIndexes = nil;
        }
    }
    else {
        [self reloadData];
    }
}

#pragma mark Loading Cell

- (void)setShowLoadingCell:(BOOL)showLoadingCell {
    [self setShowLoadingCell:showLoadingCell animated:NO];
}

- (void)setShowLoadingCell:(BOOL)showLoadingCell animated:(BOOL)animated {
    if (_showLoadingCell != showLoadingCell) {
        if (animated) {
            NSIndexPath * indexPath = self.loadingIndexPath;
            
            if (showLoadingCell) {
                [self.collectionView insertItemsAtIndexPaths:@[indexPath]];
            }
            else {
                [self.collectionView deleteItemsAtIndexPaths:@[indexPath]];
            }
        }
        
        _showLoadingCell = showLoadingCell;
    }
}

- (NSIndexPath *)loadingIndexPath {
    NSUInteger sections = [self.resultsController.sections count];
    
    if (!sections) {
        return nil;
    }
    
    NSUInteger rows = [[self.resultsController.sections objectAtIndex:(sections - 1)] numberOfObjects];
    
    return [NSIndexPath indexPathForRow:rows inSection:(sections - 1)];
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
