//
//  MLArrayCollectionViewController.m
//  ViewControllers
//
//  Created by Joachim Kret on 29.03.2015.
//  Copyright (c) 2015 Joachim Kret. All rights reserved.
//

#import "MLArrayCollectionViewController.h"
#import "RZCollectionList.h"
#import "RZBaseCollectionList+MLResultsController.h"
#import "RZArrayCollectionList+MLResultsController.h"
#import "MLCollectionViewDataSource.h"
#import "MLCollectionViewFlowLayout.h"
#import "MLCustomCollectionReusableView.h"
#import "MLButtonCollectionViewCell.h"

#pragma mark - MLArrayCollectionViewController

@interface MLArrayCollectionViewController () <MLCollectionViewDataSourceDelegate>

@property (nonatomic, readwrite, strong) RZArrayCollectionList * resultsController;
@property (nonatomic, readwrite, strong) MLCollectionViewDataSource * dataSource;

@end

#pragma mark -

@implementation MLArrayCollectionViewController

+ (Class)defaultCollectionViewLayoutClass {
    return [MLCollectionViewFlowLayout class];
}

#pragma mark View

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.collectionView.backgroundColor = [UIColor whiteColor];
    [MLButtonCollectionViewCell registerCellWithCollectionView:self.collectionView];
    
    self.resultsController = [[RZArrayCollectionList alloc] initWithArray:@[] sectionNameKeyPath:nil];
    self.dataSource = [[MLCollectionViewDataSource alloc] initWithCollectionView:self.collectionView
                                                               resultsController:self.resultsController
                                                                        delegate:self];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                                           target:self
                                                                                           action:@selector(addAction:)];
}

#pragma mark Actions

- (IBAction)addAction:(id)sender {
    [self.resultsController addObject:[NSDate date] toSection:0];
}

- (void)removeCellAtIndexPath:(NSIndexPath *)indexPath {
    [self.resultsController removeObjectAtIndexPath:indexPath];
}

#pragma mark MLCollectionViewDataSourceDelegate

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForObject:(id)object atIndexPath:(NSIndexPath *)indexPath {
    MLButtonCollectionViewCell * cell = [MLButtonCollectionViewCell cellForCollectionView:collectionView indexPath:indexPath];
    cell.textLabel.text = [object description];
    return cell;
}

@end
