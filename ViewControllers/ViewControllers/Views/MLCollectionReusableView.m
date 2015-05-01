//
//  MLCollectionReusableView.m
//  ViewControllers
//
//  Created by Joachim Kret on 22.11.2014.
//  Copyright (c) 2014 Joachim Kret. All rights reserved.
//

#import "MLCollectionReusableView.h"

#pragma mark - MLCollectionReusableView

@implementation MLCollectionReusableView

+ (NSString *)defaultSuplementaryViewOfKind {
    return UICollectionElementKindSectionHeader;
}

+ (NSString *)reuseIdentifier {
    return NSStringFromClass([self class]);
}

+ (NSString *)nibName {
    return nil;
}

+ (void)registerReusableViewWithCollectionView:(UICollectionView *)collectionView {
    [self registerReusableViewOfKind:[self defaultSuplementaryViewOfKind] withCollectionView:collectionView];
}

+ (void)registerReusableViewOfKind:(NSString *)kind withCollectionView:(UICollectionView *)collectionView {
    NSParameterAssert(kind);
    NSParameterAssert(collectionView);
    
    if ([self nibName]) {
        NSBundle * bundle = [NSBundle bundleForClass:[self class]];
        UINib * nib = [UINib nibWithNibName:[self nibName] bundle:bundle];
        [collectionView registerNib:nib forSupplementaryViewOfKind:kind withReuseIdentifier:[self reuseIdentifier]];
    }
    else {
        [collectionView registerClass:[self class] forSupplementaryViewOfKind:kind withReuseIdentifier:[self reuseIdentifier]];
    }
}

+ (id)reusableViewForCollectionView:(UICollectionView *)collectionView indexPath:(NSIndexPath *)indexPath {
    return [self reusableViewOfKind:[self defaultSuplementaryViewOfKind] forCollectionView:collectionView indexPath:indexPath];
}

+ (id)reusableViewOfKind:(NSString *)kind forCollectionView:(UICollectionView *)collectionView indexPath:(NSIndexPath *)indexPath {
    NSParameterAssert(kind);
    NSParameterAssert(collectionView);
    NSParameterAssert(indexPath);
    
    return [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:[self reuseIdentifier] forIndexPath:indexPath];
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

#pragma mark Accessors

- (UICollectionView *)collectionView {
    return (UICollectionView *)[self findResponderForClass:[UICollectionView class] responder:self];
}

- (UIViewController *)viewController {
    return (UIViewController *)[self findResponderForClass:[UIViewController class] responder:self];
}

#pragma mark Configure Reusable View

- (void)configureWithObject:(id)anObject indexPath:(NSIndexPath *)indexPath {
    // Subclasses can override this method
}

#pragma mark Private Methods

- (UIResponder *)findResponderForClass:(Class)class responder:(UIResponder *)responder {
    NSParameterAssert(responder);
    
    while ((responder = [responder nextResponder])) {
        if ([responder isKindOfClass:class]) {
            return responder;
        }
    }
    
    return nil;
}

@end
