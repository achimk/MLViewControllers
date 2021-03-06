//
//  MLTableViewDataSource.m
//  ViewControllers
//
//  Created by Joachim Kret on 07.03.2015.
//  Copyright (c) 2015 Joachim Kret. All rights reserved.
//

#import "MLTableViewDataSource.h"

#pragma mark - MLTableViewDataSource

@interface MLTableViewDataSource () <MLResultsControllerObserver>

@property (nonatomic, readwrite, assign) BOOL showLoadingCell;

@end

#pragma mark -

@implementation MLTableViewDataSource

#pragma mark Init / Dealloc

- (instancetype)initWithTableView:(UITableView *)tableView resultsController:(id <MLResultsController>)resultsController delegate:(id <MLTableViewDataSourceDelegate>)delegate {
    NSParameterAssert(tableView);
    
    if (self = [super init]) {
        _showLoadingCell = NO;
        _showSectionHeaders = NO;
        _animateTableChanges = YES;
        _clearsSelectionOnReloadData = NO;
        _reloadOnCurrentLocaleChange = NO;
        _addSectionAnimation = _updateSectionAnimation
                             = _removeSectionAnimation
                             = _addObjectAnimation
                             = _updateObjectAnimation
                             = _removeSectionAnimation
                             = UITableViewRowAnimationAutomatic;
        
        __weak typeof(tableView) weakTableView = tableView;
        _tableView = weakTableView;
        tableView.dataSource = self;
        
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
    _tableView.dataSource = nil;
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

- (void)setAllAnimations:(UITableViewRowAnimation)animation {
    [self setAllSectionAnimations:animation];
    [self setAllObjectAnimations:animation];
}

- (void)setAllSectionAnimations:(UITableViewRowAnimation)animation {
    self.addSectionAnimation = animation;
    self.removeSectionAnimation = animation;
    self.updateObjectAnimation = animation;
}

- (void)setAllObjectAnimations:(UITableViewRowAnimation)animation {
    self.addObjectAnimation = animation;
    self.updateObjectAnimation = animation;
    self.removeObjectAnimation = animation;
}

- (void)setDelegate:(id<MLTableViewDataSourceDelegate>)delegate {
    if (delegate) {
        __weak typeof(delegate)weakDelegate = delegate;
        _delegate = weakDelegate;
        
        [self reloadData];
    }
    else {
        _delegate = nil;
    }
}

#pragma mark Reload Data

- (void)reloadData {
    NSAssert2([NSThread isMainThread], @"%@: %@ must be called on main thread!", [self class], NSStringFromSelector(_cmd));
    self.showLoadingCell = self.shouldShowLoadingCell;
    
    if (self.clearsSelectionOnReloadData) {
        [self.tableView reloadData];
    }
    else {
        NSArray * selectedItems = [[self.tableView indexPathsForSelectedRows] copy];
        
        [self.tableView reloadData];
        
        for (NSIndexPath * indexPath in selectedItems) {
            [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        }
    }
}

#pragma mark Loading Cell

- (void)updateLoadingCell {
    [self updateLoadingCellAnimated:self.animateTableChanges];
}

- (void)updateLoadingCellAnimated:(BOOL)animated {
    BOOL showLoadingCell = self.shouldShowLoadingCell;
    NSIndexPath * indexPath = self.loadingIndexPath;
    
    if (self.showLoadingCell != showLoadingCell) {
        self.showLoadingCell = showLoadingCell;
        
        if (animated) {
            [self.tableView beginUpdates];
            
            if (showLoadingCell) {
                [self.tableView insertSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:self.addSectionAnimation];
                [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:self.addObjectAnimation];
            }
            else {
                [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:self.removeObjectAnimation];
                [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:self.removeSectionAnimation];
            }
            
            [self.tableView endUpdates];
        }
        else {
            [self reloadData];
        }
    }
    else if (showLoadingCell) {
        id cell = [self.tableView cellForRowAtIndexPath:indexPath];
        
        if (cell) {
            if (animated) {
                [self.tableView beginUpdates];
                [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:self.updateObjectAnimation];
                [self.tableView endUpdates];
            }
            else {
                [self reloadData];
            }

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

#pragma mark UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger numberOfSections = self.resultsController.sections.count;
    
    if (indexPath.section == numberOfSections) {
        id <MLTableViewLoadingDataSourceDelegate> delegate = (id <MLTableViewLoadingDataSourceDelegate>)self.delegate;
        return [delegate tableView:tableView loadingCellAtIndexPath:indexPath];
    }
    
    return [self.delegate tableView:tableView cellForRowAtIndexPath:indexPath];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSUInteger numberOfSections = self.resultsController.sections.count;
    
    if (self.showLoadingCell) {
        numberOfSections++;
    }
    
    return numberOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSUInteger numberOfSections = self.resultsController.sections.count;
    
    if (section == numberOfSections) {
        return 1;
    }
    
    id <MLResultsSectionInfo> sectionInfo = [self.resultsController.sections objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString * sectionTitle = nil;
    
    if ([self.delegate respondsToSelector:@selector(tableView:titleForHeaderInSection:)]) {
        sectionTitle = [self.delegate tableView:tableView titleForHeaderInSection:section];
    }
    else if (self.showSectionHeaders) {
        id <MLResultsSectionInfo> sectionInfo = [self.resultsController.sections objectAtIndex:section];
        sectionTitle = sectionInfo.name;
    }
    
    return sectionTitle;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    NSString * sectionTitle = nil;
    
    if ([self.delegate respondsToSelector:@selector(tableView:titleForFooterInSection:)]) {
        sectionTitle = [self.delegate tableView:tableView titleForFooterInSection:section];
    }
    
    return sectionTitle;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.showLoadingCell && [indexPath isEqual:self.loadingIndexPath]) {
        return NO;
    }
    
    BOOL canEdit = NO;
    if ([self.delegate respondsToSelector:@selector(tableView:canEditObject:atIndexPath:)]) {
        id object = [self.resultsController objectAtIndexPath:indexPath];
        canEdit = [self.delegate tableView:tableView canEditObject:object atIndexPath:indexPath];
    }
    
    return canEdit;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.showLoadingCell && [indexPath isEqual:self.loadingIndexPath]) {
        return NO;
    }
    
    BOOL canMove = NO;
    if ([self.delegate respondsToSelector:@selector(tableView:canMoveObject:atIndexPath:)]) {
        id object = [self.resultsController objectAtIndexPath:indexPath];
        canMove = [self.delegate tableView:tableView canMoveObject:object atIndexPath:indexPath];
    }
    
    return canMove;
}

#warning Implement missing data source methods!
//- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView; {
//    return nil;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
//    return NSNotFound;
//}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(tableView:commitEditingStyle:forRowAtIndexPath:)]) {
        [self.delegate tableView:tableView commitEditingStyle:editingStyle forRowAtIndexPath:indexPath];
    }
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    if ([self.delegate respondsToSelector:@selector(tableView:moveRowAtIndexPath:toIndexPath:)]) {
        [self.delegate tableView:tableView moveRowAtIndexPath:sourceIndexPath toIndexPath:destinationIndexPath];
    }
}

#pragma mark MLResultsControllerObserver

- (void)resultsControllerWillChangeContent:(id<MLResultsController>)resultsController {
    if (self.animateTableChanges) {
        [self.tableView beginUpdates];
    }
}

- (void)resultsController:(id<MLResultsController>)resultsController didChangeSection:(id<MLResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(MLResultsChangeType)type {
    if (!self.animateTableChanges) {
        return;
    }
    
    switch (type) {
        case MLResultsChangeTypeInsert: {
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:self.addSectionAnimation];
        } break;
            
        case MLResultsChangeTypeDelete: {
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:self.removeSectionAnimation];
        } break;
            
        case MLResultsChangeTypeMove:
        case MLResultsChangeTypeUpdate: {
            // Nothing to do...
        }break;
    }
}

- (void)resultsController:(id<MLResultsController>)resultsController didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(MLResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    if (!self.animateTableChanges) {
        return;
    }
    
    switch (type) {
        case MLResultsChangeTypeInsert: {
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:self.addObjectAnimation];
        } break;
            
        case MLResultsChangeTypeDelete: {
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:self.removeObjectAnimation];
        } break;
            
        case MLResultsChangeTypeMove: {
            [self.tableView moveRowAtIndexPath:indexPath toIndexPath:newIndexPath];
        } break;
            
        case MLResultsChangeTypeUpdate: {
            UITableViewCell * cell = [self.tableView cellForRowAtIndexPath:indexPath];
            
            if (cell) {
                if ([self.delegate respondsToSelector:@selector(tableView:updateCell:forObject:atIndexPath:)]) {
                    [self.delegate tableView:self.tableView updateCell:cell forObject:anObject atIndexPath:indexPath];
                }
                else {
                    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:self.updateObjectAnimation];
                }
            }
        } break;
    }
}

- (void)resultsControllerDidChangeContent:(id<MLResultsController>)resultsController {
    if (self.animateTableChanges) {
        [self.tableView endUpdates];
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
    if ([self.delegate conformsToProtocol:@protocol(MLTableViewLoadingDataSourceDelegate)]) {
        id <MLTableViewLoadingDataSourceDelegate> delegate = (id <MLTableViewLoadingDataSourceDelegate>)self.delegate;
        NSIndexPath * indexPath = self.loadingIndexPath;
        UITableView * tableView = self.tableView;
        
        return [delegate tableView:tableView shouldShowLoadingCellAtIndexPath:indexPath];
    }
    
    return NO;
}

@end
