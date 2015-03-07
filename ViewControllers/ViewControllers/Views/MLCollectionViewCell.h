//
//  MLCollectionViewCell.h
//  ViewControllers
//
//  Created by Joachim Kret on 22.11.2014.
//  Copyright (c) 2014 Joachim Kret. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, MLCollectionViewCellConfigureType) {
    MLCollectionViewCellConfigureDefault,
    MLCollectionViewCellConfigureDynamicResize
};

@protocol MLCollectionViewCellProtocol <NSObject>

@required
// Method for dynamic resizing cell size
+ (CGSize)cellSizeForData:(id)dataObject collectionView:(UICollectionView *)collectionView indexPath:(NSIndexPath *)indexPath;

// Configure cell for data
- (void)configureForData:(id)dataObject collectionView:(UICollectionView *)collectionView indexPath:(NSIndexPath *)indexPath;
- (void)configureForData:(id)dataObject collectionView:(UICollectionView *)collectionView indexPath:(NSIndexPath *)indexPath type:(MLCollectionViewCellConfigureType)type;

@end

@interface MLCollectionViewCell : UICollectionViewCell <MLCollectionViewCellProtocol>

+ (NSString *)defaultCollectionViewCellIdentifier;
+ (NSString *)defaultCollectionViewCellNibName;
+ (UINib *)defaultNib;

+ (void)registerCellWithCollectionView:(UICollectionView *)collectionView;
+ (id)cellForCollectionView:(UICollectionView *)collectionView indexPath:(NSIndexPath *)indexPath;

@end

@interface MLCollectionViewCell (MLSubclassOnly)

- (void)finishInitialize;

@end