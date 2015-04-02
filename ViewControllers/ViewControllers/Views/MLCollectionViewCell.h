//
//  MLCollectionViewCell.h
//  ViewControllers
//
//  Created by Joachim Kret on 22.11.2014.
//  Copyright (c) 2014 Joachim Kret. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MLCellConfiguration.h"

@interface MLCollectionViewCell : UICollectionViewCell <MLCellConfiguration>

// Register cell with collection view.
+ (void)registerCellWithCollectionView:(UICollectionView *)collectionView;

// Dequeue registered cell for collection view.
+ (id)cellForCollectionView:(UICollectionView *)collectionView indexPath:(NSIndexPath *)indexPath;

// Corresponding collection view found in responder chain.
- (UICollectionView *)collectionView;

// Corresponding view controller found in responder chain.
- (UIViewController *)viewController;

@end

@interface MLCollectionViewCell (MLCellSize)

// Default cell size. Returns size of cell when loaded from nib file otherwise CGSizeZero.
+ (CGSize)cellSize;

// Dynamic cell size. Populate with data and compute the size by autolayout.
+ (CGSize)cellSizeWithObject:(id)anObject collectionView:(UICollectionView *)collectionView indexPath:(NSIndexPath *)indexPath;

@end

@interface MLCollectionViewCell (MLSubclassOnly)

// Common initializer for initWithFrame: and awakeFromNib. You don't need to call super implementation.
- (void)finishInitialize;

@end