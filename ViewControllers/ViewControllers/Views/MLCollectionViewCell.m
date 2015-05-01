//
//  MLCollectionViewCell.m
//  ViewControllers
//
//  Created by Joachim Kret on 22.11.2014.
//  Copyright (c) 2014 Joachim Kret. All rights reserved.
//

#import "MLCollectionViewCell.h"

#pragma mark - MLCollectionViewCell

@implementation MLCollectionViewCell

+ (NSString *)reuseIdentifier {
    return NSStringFromClass([self class]);
}

+ (NSString *)nibName {
    return nil;
}

+ (void)registerCellWithCollectionView:(UICollectionView *)collectionView {
    NSParameterAssert(collectionView);
    
    if ([self nibName]) {
        NSBundle * bundle = [NSBundle bundleForClass:[self class]];
        UINib * nib = [UINib nibWithNibName:[self nibName] bundle:bundle];
        [collectionView registerNib:nib forCellWithReuseIdentifier:[self reuseIdentifier]];
    }
    else {
        [collectionView registerClass:[self class] forCellWithReuseIdentifier:[self reuseIdentifier]];
    }
}

+ (id)cellForCollectionView:(UICollectionView *)collectionView indexPath:(NSIndexPath *)indexPath {
    NSParameterAssert(collectionView);
    NSParameterAssert(indexPath);
    
    return [collectionView dequeueReusableCellWithReuseIdentifier:[self reuseIdentifier] forIndexPath:indexPath];
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
    // Sublcasses can override this method
}

#pragma mark Accessors

- (UICollectionView *)collectionView {
    return (UICollectionView *)[self findResponderForClass:[UICollectionView class] responder:self];
}

- (UIViewController *)viewController {
    return (UIViewController *)[self findResponderForClass:[UIViewController class] responder:self];
}

#pragma mark Configure Cell

- (void)configureWithObject:(id)anObject context:(id)context {
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
