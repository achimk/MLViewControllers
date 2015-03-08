//
//  MLCollectionViewDataSource.h
//  ViewControllers
//
//  Created by Joachim Kret on 07.03.2015.
//  Copyright (c) 2015 Joachim Kret. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MLResultsControllerProtocol.h"

@protocol MLCollectionViewDataSourceDelegate <NSObject>

@required
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForObject:(id)object atIndexPath:(NSIndexPath *)indexPath;

@end

@interface MLCollectionViewDataSource : NSObject <UICollectionViewDataSource>

@property (nonatomic, readonly, weak) UICollectionView * collectionView;
@property (nonatomic, readwrite, strong) id <MLResultsController> resultsController;
@property (nonatomic, readwrite, weak) id <MLCollectionViewDataSourceDelegate> delegate;

- (instancetype)initWithCollectionView:(UICollectionView *)collectionView resultsController:(id <MLResultsController>)resultsController delegate:(id <MLCollectionViewDataSourceDelegate>)delegate;

@end
