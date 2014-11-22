//
//  MLCollectionReusableView.h
//  ViewControllers
//
//  Created by Joachim Kret on 22.11.2014.
//  Copyright (c) 2014 Joachim Kret. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MLCollectionReusableView : UICollectionReusableView

+ (NSString *)defaultSuplementaryViewOfKind;
+ (NSString *)defaultReusableViewIdentifier;
+ (NSString *)defaultReusableViewNibName;
+ (UINib *)defaultNib;

+ (void)registerReusableViewWithCollectionView:(UICollectionView *)collectionView;
+ (void)registerReusableViewOfKind:(NSString *)kind withCollectionView:(UICollectionView *)collectionView;

+ (id)reusableViewForCollectionView:(UICollectionView *)collectionView indexPath:(NSIndexPath *)indexPath;
+ (id)reusableViewOfKind:(NSString *)kind forCollectionView:(UICollectionView *)collectionView indexPath:(NSIndexPath *)indexPath;

@end

@interface MLCollectionReusableView (MLSubclassOnly)

- (void)finishInitialize;
- (void)configureForData:(id)data collectionView:(UICollectionView *)collectionView indexPath:(NSIndexPath *)indexPath;

@end