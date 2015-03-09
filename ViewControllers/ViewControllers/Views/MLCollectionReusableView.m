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

+ (void)registerReusableViewWithCollectionView:(UICollectionView *)collectionView {
    [self registerReusableViewOfKind:[self defaultSuplementaryViewOfKind] withCollectionView:collectionView];
}

+ (void)registerReusableViewOfKind:(NSString *)kind withCollectionView:(UICollectionView *)collectionView {
    NSParameterAssert(kind);
    NSParameterAssert(collectionView);
    
    if ([self defaultReusableViewNibName]) {
        NSBundle * bundle = [NSBundle bundleForClass:[self class]];
        UINib * nib = [UINib nibWithNibName:[self defaultReusableViewNibName] bundle:bundle];
        [collectionView registerNib:nib forSupplementaryViewOfKind:kind withReuseIdentifier:[self defaultReusableViewNibName]];
    }
    else {
        [collectionView registerClass:[self class] forSupplementaryViewOfKind:kind withReuseIdentifier:[self defaultReusableViewIdentifier]];
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
    return [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:identifier forIndexPath:indexPath];
}

#pragma mark Initialize

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self finishInitialize];
    }
    
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self finishInitialize];
}

- (void)finishInitialize {
    // Subclasses can override this method
}

#pragma mark MLCollectionReusableViewProtocol

+ (CGSize)reusableViewSize {
    NSString * nibName = [self defaultReusableViewNibName];
    
    if (!nibName) {
        return CGSizeZero;
    }
    
    static NSMutableDictionary * dictionaryOfCellSizes = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dictionaryOfCellSizes = [[NSMutableDictionary alloc] init];
    });
    
    NSValue * sizeValue = dictionaryOfCellSizes[nibName];
    
    if (!sizeValue) {
        NSBundle * bundle = [NSBundle bundleForClass:[self class]];
        UINib * nib = [UINib nibWithNibName:nibName bundle:bundle];
        NSArray * nibObjects = [nib instantiateWithOwner:nil options:nil];
        NSAssert2([nibObjects count] > 0 && [[nibObjects objectAtIndex:0] isKindOfClass:[self class]], @"Nib '%@' doesn't appear to contain a valid %@", nibName, [self class]);
        
        if (nibObjects.count) {
            UICollectionReusableView * cell = (UICollectionReusableView *)nibObjects[0];
            sizeValue = [NSValue valueWithCGSize:cell.bounds.size];
            [dictionaryOfCellSizes setObject:sizeValue forKey:nibName];
        }
    }
    
    return (sizeValue) ? sizeValue.CGSizeValue : CGSizeZero;
}

- (void)configureForData:(id)data collectionView:(UICollectionView *)collectionView indexPath:(NSIndexPath *)indexPath {
    // Subclasses can override this method
}

@end
