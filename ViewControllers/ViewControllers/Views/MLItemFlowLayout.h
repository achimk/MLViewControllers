//
//  MLItemFlowLayout.h
//  ViewControllers
//
//  Created by Joachim Kret on 19.05.2015.
//  Copyright (c) 2015 Joachim Kret. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef struct MLItemSpacing {
    CGFloat x;
    CGFloat y;
} MLItemSpacing;

static inline MLItemSpacing MLItemSpacingMake(CGFloat x, CGFloat y) {
    MLItemSpacing spacing = {x, y};
    return spacing;
};

@protocol MLCollectionViewDelegateItemFlowLayout <UICollectionViewDelegateFlowLayout>

@required
- (NSUInteger)collectionView:(UICollectionView *)collectionView numberOfColumnsInSection:(NSInteger)section;

@optional
- (CGFloat)collectionView:(UICollectionView *)collectionView heightForItemsInSection:(NSInteger)section;
- (CGFloat)sectionSpacingForCollectionView:(UICollectionView *)collectionView;

@end

@interface MLItemFlowLayout : UICollectionViewFlowLayout

#warning Replace MLItemSpacing with UIOffset
@property (nonatomic, readwrite, assign) MLItemSpacing itemSpacing;
@property (nonatomic, readwrite, weak) id <MLCollectionViewDelegateItemFlowLayout> delegate;

@end
