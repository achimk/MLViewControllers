//
//  MLCollectionViewCell.m
//  ViewControllers
//
//  Created by Joachim Kret on 22.11.2014.
//  Copyright (c) 2014 Joachim Kret. All rights reserved.
//

#import "MLCollectionViewCell.h"

@implementation MLCollectionViewCell

+ (NSString *)defaultCollectionViewCellIdentifier {
    return NSStringFromClass([self class]);
}

+ (NSString *)defaultCollectionViewCellNibName {
    return nil;
}

+ (UINib *)defaultNib {
    if ([self defaultCollectionViewCellNibName]) {
        NSBundle * bundle = [NSBundle bundleForClass:[self class]];
        return [UINib nibWithNibName:[self defaultCollectionViewCellNibName] bundle:bundle];
    }
    
    return nil;
}

+ (void)registerCellWithCollectionView:(UICollectionView *)collectionView {
    NSParameterAssert(collectionView);
    
    if ([self defaultCollectionViewCellNibName]) {
        [collectionView registerNib:[self defaultNib] forCellWithReuseIdentifier:[self defaultCollectionViewCellNibName]];
    }
    else if ([self defaultCollectionViewCellIdentifier]) {
        [collectionView registerClass:[self class] forCellWithReuseIdentifier:[self defaultCollectionViewCellIdentifier]];
    }
    else {
        NSAssert(NO, @"Can't register cell '%@' without nib name or cell identifier", [self class]);
    }
}

+ (id)cellForCollectionView:(UICollectionView *)collectionView indexPath:(NSIndexPath *)indexPath {
    NSParameterAssert(collectionView);
    NSParameterAssert(indexPath);
    
    NSString * cellIdentifier = ([self defaultCollectionViewCellNibName]) ?: [self defaultCollectionViewCellIdentifier];
    UICollectionViewCell * cell = nil;
    
    if (cellIdentifier) {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    }
    else {
        NSAssert(NO, @"Can't dequeue cell '%@' without nib name or cell identifier", [self class]);
    }
    
    return cell;
}

#pragma mark Init

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self finishInitialize];
    }
    
    return self;
}

#pragma mark Awake

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self finishInitialize];
}

#pragma mark Subclass Methods

- (void)finishInitialize {
}

- (void)configureForData:(id)dataObject collectionView:(UICollectionView *)collectionView indexPath:(NSIndexPath *)indexPath {
}

@end
