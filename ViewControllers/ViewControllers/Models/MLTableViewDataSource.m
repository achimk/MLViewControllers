//
//  MLTableViewDataSource.m
//  ViewControllers
//
//  Created by Joachim Kret on 07.03.2015.
//  Copyright (c) 2015 Joachim Kret. All rights reserved.
//

#import "MLTableViewDataSource.h"

@interface MLTableViewDataSource () <MLResultsControllerObserver>

@property (nonatomic, readwrite, weak) UITableView * tableView;
@property (nonatomic, readwrite, assign) BOOL reloadAfterAnimation;

@end

@implementation MLTableViewDataSource

- (instancetype)init {
    METHOD_USE_DESIGNATED_INIT;
    return nil;
}

- (instancetype)initWithTableView:(UITableView *)tableView resultsController:(id <MLResultsController>)resultsController delegate:(id <MLTableViewDataSourceDelegate>)delegate {
    NSParameterAssert(tableView);
    
    if (self = [super init]) {
        _showSectionHeaders = NO;
        _animateTableChanges = YES;
        _reloadAfterAnimation = NO;
        _addSectionAnimation = _removeSectionAnimation = _addObjectAnimation = _updateObjectAnimation = _removeSectionAnimation = UITableViewRowAnimationAutomatic;
        
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
        }
    }
    
    return self;
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
        
        [self.tableView reloadData];
    }
}

- (void)setAllAnimations:(UITableViewRowAnimation)animation {
    [self setAllSectionAnimations:animation];
    [self setAllObjectAnimations:animation];
}

- (void)setAllSectionAnimations:(UITableViewRowAnimation)animation {
    self.addSectionAnimation = animation;
    self.removeSectionAnimation = animation;
}

- (void)setAllObjectAnimations:(UITableViewRowAnimation)animation {
    self.addObjectAnimation = animation;
    self.updateObjectAnimation = animation;
    self.removeObjectAnimation = animation;
}

#pragma mark UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    id object = [self.resultsController objectAtIndexPath:indexPath];
    return [self.delegate tableView:self.tableView cellForObject:object atIndexPath:indexPath];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.resultsController.sections count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
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
    BOOL canEdit = NO;
    
    if ([self.delegate respondsToSelector:@selector(tableView:canEditObject:atIndexPath:)]) {
        id object = [self.resultsController objectAtIndexPath:indexPath];
        canEdit = [self.delegate tableView:tableView canEditObject:object atIndexPath:indexPath];
    }
    
    return canEdit;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
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
        case MLResultsChangeTypeUpdate: break;
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
                    self.reloadAfterAnimation = YES;
                }
            }
        } break;
    }
}

- (void)resultsControllerDidChangeContent:(id<MLResultsController>)resultsController {
    if (self.animateTableChanges) {
        if (self.reloadAfterAnimation) {
            [CATransaction begin];
            [CATransaction setCompletionBlock:^{
                [self.tableView reloadData];
            }];
        }
        
        [self.tableView endUpdates];
        
        if (self.reloadAfterAnimation) {
            self.reloadAfterAnimation = NO;
            [CATransaction commit];
        }
    }
    else {
        [self.tableView reloadData];
    }
}

@end
