//
//  MLCollectionViewDataSource.h
//  ViewControllers
//
//  Created by Joachim Kret on 07.03.2015.
//  Copyright (c) 2015 Joachim Kret. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MLResultsControllerProtocol.h"

/**
 MLCollectionViewDataSourceDelegate
 */
@protocol MLCollectionViewDataSourceDelegate <NSObject>

@required
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath;

@optional
- (void)collectionView:(UICollectionView *)collectionView updateCell:(UICollectionViewCell *)cell forObject:(id)object atIndexPath:(NSIndexPath *)indexPath;
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath;

@end

/**
 MLCollectionViewLoadingDataSourceDelegate
 */
@protocol MLCollectionViewLoadingDataSourceDelegate <MLCollectionViewDataSourceDelegate>

@required
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowLoadingCellAtIndexPath:(NSIndexPath *)indexPath;
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView loadingCellAtIndexPath:(NSIndexPath *)indexPath;

@end

/**
 MLCollectionViewDataSource
 */
@interface MLCollectionViewDataSource : NSObject <UICollectionViewDataSource>

@property (nonatomic, readonly, weak) UICollectionView * collectionView;
@property (nonatomic, readwrite, strong) id <MLResultsController> resultsController;
@property (nonatomic, readwrite, weak) id <MLCollectionViewDataSourceDelegate> delegate;
@property (nonatomic, readwrite, assign) BOOL clearsSelectionOnReloadData;
@property (nonatomic, readwrite, assign) BOOL reloadOnCurrentLocaleChange;
@property (nonatomic, readwrite, assign, getter = shouldUseBatchUpdating) BOOL useBatchUpdating;
@property (nonatomic, readwrite, assign, getter = shouldAnimateCollectionChanges) BOOL animateCollectionChanges;

- (instancetype)initWithCollectionView:(UICollectionView *)collectionView resultsController:(id <MLResultsController>)resultsController delegate:(id <MLCollectionViewDataSourceDelegate>)delegate NS_DESIGNATED_INITIALIZER;

- (BOOL)isLoadingSection:(NSUInteger)section;
- (BOOL)isLoadingIndexPath:(NSIndexPath *)indexPath;
- (void)updateLoadingCell;
- (void)updateLoadingCellAnimated:(BOOL)animated;

- (void)reloadData;

@end
