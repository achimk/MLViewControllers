//
//  MLCollectionViewCell.h
//  ViewControllers
//
//  Created by Joachim Kret on 22.11.2014.
//  Copyright (c) 2014 Joachim Kret. All rights reserved.
//

#import <UIKit/UIKit.h>

// Cell configuration types.
typedef NS_ENUM(NSUInteger, MLCollectionViewCellConfigureType) {
    MLCollectionViewCellConfigureDefault,           // Default type when cell needs to be populated with all resources.
    MLCollectionViewCellConfigureDynamicResize      // Dynamic resize type, called from cellSizeForData:collectionView:indexPath: to compute cell size.
};

@protocol MLCollectionViewCellProtocol <NSObject>

@required
// Default cell size. Returns size of cell when loaded from nib file otherwise CGSizeZero.
+ (CGSize)cellSize;

// Dynamic cell size. Populate with data and compute the size by autolayout.
+ (CGSize)cellSizeForData:(id)dataObject collectionView:(UICollectionView *)collectionView indexPath:(NSIndexPath *)indexPath;

// Configure cell for data. Default behaviour when dynamic cell size is not used.
- (void)configureForData:(id)dataObject collectionView:(UICollectionView *)collectionView indexPath:(NSIndexPath *)indexPath;

// Configure cell for data and define configure type. Used to compute dynamic cell size and prevent to load uneccessary resources (eg. big images or networking calls).
- (void)configureForData:(id)dataObject collectionView:(UICollectionView *)collectionView indexPath:(NSIndexPath *)indexPath type:(MLCollectionViewCellConfigureType)type;

@end

@interface MLCollectionViewCell : UICollectionViewCell <MLCollectionViewCellProtocol>

// Register cell with collection view.
+ (void)registerCellWithCollectionView:(UICollectionView *)collectionView;

// Dequeue registered cell for collection view.
+ (id)cellForCollectionView:(UICollectionView *)collectionView indexPath:(NSIndexPath *)indexPath;

@end

@interface MLCollectionViewCell (MLSubclassOnly)

// Define default cell identifier. Used for register and dequeue class cell from collection view.
+ (NSString *)defaultCollectionViewCellIdentifier;

// Define default cell nib name. Used for register and dequeue nib cell from collection view.
+ (NSString *)defaultCollectionViewCellNibName;

// Common initializer for initWithFrame: and awakeFromNib. You don't need to call super implementation.
- (void)finishInitialize;

@end