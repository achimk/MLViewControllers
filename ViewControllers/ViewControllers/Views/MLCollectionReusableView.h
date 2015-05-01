//
//  MLCollectionReusableView.h
//  ViewControllers
//
//  Created by Joachim Kret on 22.11.2014.
//  Copyright (c) 2014 Joachim Kret. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MLCellConfiguration.h"

@interface MLCollectionReusableView : UICollectionReusableView <MLCellConfiguration>

// Register reuseable view with collection view (using default kind of suplementary view).
+ (void)registerReusableViewWithCollectionView:(UICollectionView *)collectionView;

// Register reusable view with collection view by kind.
+ (void)registerReusableViewOfKind:(NSString *)kind withCollectionView:(UICollectionView *)collectionView;

// Dequeue registered reusable view for collection view (using default kind of suplementary view).
+ (id)reusableViewForCollectionView:(UICollectionView *)collectionView indexPath:(NSIndexPath *)indexPath;

// Dequeue registered reusable view for collection view by kind.
+ (id)reusableViewOfKind:(NSString *)kind forCollectionView:(UICollectionView *)collectionView indexPath:(NSIndexPath *)indexPath;

// Corresponding collection view found in responder chain.
- (UICollectionView *)collectionView;

// Corresponding view controller found in responder chain.
- (UIViewController *)viewController;

@end

@interface MLCollectionReusableView (MLSubclassOnly)

// Default kind of suplementary view.
+ (NSString *)defaultSuplementaryViewOfKind;

// Common initializer for initWithFrame: and awakeFromNib. You don't need to call super implementation.
- (void)finishInitialize;

@end