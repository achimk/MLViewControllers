//
//  MLCollectionViewDataSource.m
//  ViewControllers
//
//  Created by Joachim Kret on 07.03.2015.
//  Copyright (c) 2015 Joachim Kret. All rights reserved.
//

#import "MLCollectionViewDataSource.h"

#pragma mark - MLCollectionViewDataSource

@interface MLCollectionViewDataSource ()

@property (nonatomic, readwrite, weak) UICollectionView * collectionView;

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
        self.collectionView = collectionView;
        self.collectionView.dataSource = self;
        self.resultsController = resultsController;
        self.delegate = delegate;
    }
    
    return self;
}

#pragma mark UICollectionViewDataSource

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    id object = [self.resultsController objectAtIndexPath:indexPath];
    return [self.delegate collectionView:self.collectionView cellForObject:object atIndexPath:indexPath];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return [self.resultsController.sections count];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    id <MLResultsSectionInfo> sectionInfo = [self.resultsController.sections objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

@end
