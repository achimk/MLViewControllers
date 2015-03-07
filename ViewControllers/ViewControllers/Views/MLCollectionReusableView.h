//
//  MLCollectionReusableView.h
//  ViewControllers
//
//  Created by Joachim Kret on 22.11.2014.
//  Copyright (c) 2014 Joachim Kret. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MLCollectionReusableViewProtocol <NSObject>

@required
// Default reusable view size. Returns size of reusable view when loaded from nib file otherwise CGSizeZero.
+ (CGSize)reusableViewSize;

// Configure cell for data.
- (void)configureForData:(id)data collectionView:(UICollectionView *)collectionView indexPath:(NSIndexPath *)indexPath;

@end


@interface MLCollectionReusableView : UICollectionReusableView <MLCollectionReusableViewProtocol>

// Register reuseable view with collection view (using default kind of suplementary view).
+ (void)registerReusableViewWithCollectionView:(UICollectionView *)collectionView;

// Register reusable view with collection view by kind.
+ (void)registerReusableViewOfKind:(NSString *)kind withCollectionView:(UICollectionView *)collectionView;

// Dequeue registered reusable view for collection view (using default kind of suplementary view).
+ (id)reusableViewForCollectionView:(UICollectionView *)collectionView indexPath:(NSIndexPath *)indexPath;

// Dequeue registered reusable view for collection view by kind.
+ (id)reusableViewOfKind:(NSString *)kind forCollectionView:(UICollectionView *)collectionView indexPath:(NSIndexPath *)indexPath;

@end

@interface MLCollectionReusableView (MLSubclassOnly)

// Default kind of suplementary view.
+ (NSString *)defaultSuplementaryViewOfKind;

// Define default reusable view identifier. Used for register and dequeue class of reusable view from collection view.
+ (NSString *)defaultReusableViewIdentifier;

// Define default reusable view nib name. Used for register and dequeue nib of reusable view from collection view.
+ (NSString *)defaultReusableViewNibName;

// Common initializer for initWithFrame: and awakeFromNib. You don't need to call super implementation.
- (void)finishInitialize;

@end