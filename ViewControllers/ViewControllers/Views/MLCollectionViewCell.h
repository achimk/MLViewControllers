//
//  MLCollectionViewCell.h
//  ViewControllers
//
//  Created by Joachim Kret on 22.11.2014.
//  Copyright (c) 2014 Joachim Kret. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MLCollectionViewCell : UICollectionViewCell

+ (NSString *)defaultCollectionViewCellIdentifier;
+ (NSString *)defaultCollectionViewCellNibName;
+ (UINib *)defaultNib;

+ (void)registerCellWithCollectionView:(UICollectionView *)collectionView;
+ (id)cellForCollectionView:(UICollectionView *)collectionView indexPath:(NSIndexPath *)indexPath;

@end

@interface MLCollectionViewCell (MLSubclassOnly)

- (void)finishInitialize;
- (void)configureForData:(id)dataObject collectionView:(UICollectionView *)collectionView indexPath:(NSIndexPath *)indexPath;

@end