//
//  MLCollectionReusableView.m
//  ViewControllers
//
//  Created by Joachim Kret on 22.11.2014.
//  Copyright (c) 2014 Joachim Kret. All rights reserved.
//

#import "MLCollectionReusableView.h"

@implementation MLCollectionReusableView

+ (NSString *)defaultSuplementaryViewOfKind {
    return UICollectionElementKindSectionHeader;
}

+ (NSString *)defaultReusableViewIdentifier {
    return NSStringFromClass([self class]);
}

+ (NSString *)defaultReusableViewNibName {
    return nil;
}

+ (UINib *)defaultNib {
    if ([self defaultReusableViewNibName]) {
        NSBundle * bundle = [NSBundle bundleForClass:[self class]];
        return [UINib nibWithNibName:[self defaultReusableViewNibName] bundle:bundle];
    }
    
    return nil;
}

+ (void)registerReusableViewWithCollectionView:(UICollectionView *)collectionView {
    [self registerReusableViewOfKind:[self defaultSuplementaryViewOfKind] withCollectionView:collectionView];
}

+ (void)registerReusableViewOfKind:(NSString *)kind withCollectionView:(UICollectionView *)collectionView {
    NSParameterAssert(kind);
    NSParameterAssert(collectionView);
    
    if ([self defaultReusableViewNibName]) {
        [collectionView registerNib:[self defaultNib] forSupplementaryViewOfKind:kind withReuseIdentifier:[self defaultReusableViewNibName]];
    }
    else if ([self defaultReusableViewIdentifier]) {
        [collectionView registerClass:[self class] forSupplementaryViewOfKind:kind withReuseIdentifier:[self defaultReusableViewIdentifier]];
    }
    else {
        NSAssert(NO, @"Can't register reusable view '%@' without nib name or identifier", [self class]);
    }
}

+ (id)reusableViewForCollectionView:(UICollectionView *)collectionView indexPath:(NSIndexPath *)indexPath {
    return [self reusableViewOfKind:[self defaultSuplementaryViewOfKind] forCollectionView:collectionView indexPath:indexPath];
}

+ (id)reusableViewOfKind:(NSString *)kind forCollectionView:(UICollectionView *)collectionView indexPath:(NSIndexPath *)indexPath {
    NSParameterAssert(kind);
    NSParameterAssert(collectionView);
    NSParameterAssert(indexPath);
    
    NSString * identifier = ([self defaultReusableViewNibName]) ?: [self defaultReusableViewIdentifier];
    UICollectionReusableView * reusableView = nil;
    
    if (identifier) {
        reusableView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:identifier forIndexPath:indexPath];
    }
    else {
        NSAssert(NO, @"Can't dequeue reusable view '%@' without nib name or identifier", [self class]);
    }
    
    return reusableView;
}

#pragma mark Init

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self finishInitialize];
    }
    
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self finishInitialize];
}

#pragma mark Subclass Methods

- (void)finishInitialize {
}

- (void)configureForData:(id)data collectionView:(UICollectionView *)collectionView indexPath:(NSIndexPath *)indexPath {
}

@end
