//
//  MLCollectionViewCell.h
//  ViewControllers
//
//  Created by Joachim Kret on 22.11.2014.
//  Copyright (c) 2014 Joachim Kret. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MLConfiguration.h"

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

@interface MLCollectionViewCell (MLSubclassOnly)

// Common initializer for initWithFrame: and awakeFromNib. You don't need to call super implementation.
- (void)finishInitialize;

@end