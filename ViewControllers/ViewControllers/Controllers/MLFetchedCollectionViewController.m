//
//  MLFetchedCollectionViewController.m
//  ViewControllers
//
//  Created by Joachim Kret on 29.03.2015.
//  Copyright (c) 2015 Joachim Kret. All rights reserved.
//

#import "MLFetchedCollectionViewController.h"
#import "MLCollectionViewDataSource.h"
#import "MLFetchedResultsController.h"
#import "MLCollectionViewFlowLayout.h"
#import "MLButtonCollectionViewCell.h"
#import "MLEventEntity.h"

#pragma mark - MLFetchedCollectionViewController

@interface MLFetchedCollectionViewController () <MLCollectionViewDataSourceDelegate>

@property (nonatomic, readwrite, strong) MLFetchedResultsController * fetchedResultsController;
@property (nonatomic, readwrite, strong) MLCollectionViewDataSource * dataSource;

@end

#pragma mark -

@implementation MLFetchedCollectionViewController

+ (Class)defaultCollectionViewLayoutClass {
    return [MLCollectionViewFlowLayout class];
}

#pragma mark Dealloc

- (void)dealloc {
    [[MLCoreDataStack defaultStack] saveWithBlock:^(NSManagedObjectContext *context) {
        [MLEventEntity ml_deleteAllInContext:context];
    }];
}

#pragma mark View

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.collectionView.backgroundColor = [UIColor whiteColor];
    [MLButtonCollectionViewCell registerCellWithCollectionView:self.collectionView];
    
    NSPredicate * predicate = nil;
    NSSortDescriptor * sort = [NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:YES];
    NSFetchRequest * fetchRequest = [MLEventEntity ml_requestWithPredicate:predicate withSortDescriptor:sort];
    NSManagedObjectContext * context = [[MLCoreDataStack defaultStack] managedObjectContext];
    
    self.fetchedResultsController = [[MLFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                        managedObjectContext:context
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:nil];
    
    self.dataSource = [[MLCollectionViewDataSource alloc] initWithCollectionView:self.collectionView
                                                               resultsController:self.fetchedResultsController
                                                                        delegate:self];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                                           target:self
                                                                                           action:@selector(addAction:)];
}

#pragma mark Actions

- (IBAction)addAction:(id)sender {
    [[MLCoreDataStack defaultStack] saveWithBlock:^(NSManagedObjectContext *context) {
        MLEventEntity * event = [MLEventEntity ml_createInContext:context];
        event.timestamp = [NSDate date];
    }];
}

- (void)removeCellAtIndexPath:(NSIndexPath *)indexPath {
    __weak typeof(self)weakSelf = self;
    [[MLCoreDataStack defaultStack] saveWithBlock:^(NSManagedObjectContext *context) {
        NSManagedObject * object = [weakSelf.fetchedResultsController objectAtIndexPath:indexPath];
        [context deleteObject:object];
    }];
}

#pragma mark MLCollectionViewDataSourceDelegate

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MLButtonCollectionViewCell * cell = [MLButtonCollectionViewCell cellForCollectionView:collectionView indexPath:indexPath];
    MLEventEntity * event = (MLEventEntity *)[self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = [event.timestamp description];
    return cell;
}

@end
