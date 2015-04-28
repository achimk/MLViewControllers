//
//  MLCellSizeManager.m
//  ViewControllers
//
//  Created by Joachim Kret on 28.04.2015.
//  Copyright (c) 2015 Joachim Kret. All rights reserved.
//

#import "MLCellSizeManager.h"

const CGFloat MLCellSizeManagerDefaultCellHeightPadding     = 1.0f;

#pragma mark - UIView (AutoLayout)

@interface UIView (AutoLayout)

- (void)ml_moveConstraintsToContentView;

@end

#pragma mark -

@implementation UIView (AutoLayout)

// Taken from : http://stackoverflow.com/questions/18746929/using-auto-layout-in-uitableview-for-dynamic-cell-layouts-heights
// Note that there may be performance issues with this in some cases.  Should only call in on Awake from nib or initialization and not on reuse.
- (void)ml_moveConstraintsToContentView {
    if ([self isKindOfClass:[UICollectionViewCell class]] || [self isKindOfClass:[UITableViewCell class]])
    {
        for(NSLayoutConstraint *cellConstraint in self.constraints){
            [self removeConstraint:cellConstraint];
            id firstItem = cellConstraint.firstItem == self ? self.ml_contentView : cellConstraint.firstItem;
            id secondItem = cellConstraint.secondItem == self ? self.ml_contentView : cellConstraint.secondItem;
            //There is a case where we can grab the iOS7 UITableViewCellScrollView which will break, this check is for that.
            if (([[firstItem superview] isEqual:self] && ![firstItem isEqual:self.ml_contentView]) ||
                ([[secondItem superview] isEqual:self] && ![secondItem isEqual:self.ml_contentView]))
            {
                continue;
            }
            
            NSLayoutConstraint* contentViewConstraint =
            [NSLayoutConstraint constraintWithItem:firstItem
                                         attribute:cellConstraint.firstAttribute
                                         relatedBy:cellConstraint.relation
                                            toItem:secondItem
                                         attribute:cellConstraint.secondAttribute
                                        multiplier:cellConstraint.multiplier
                                          constant:cellConstraint.constant];
            [self.ml_contentView addConstraint:contentViewConstraint];
        }
    }
}

- (UIView *)ml_contentView {
    // We know we are a collectionview cell or a tableview cell so this is safe.
    return [(UITableViewCell *)self contentView];
}

@end

#pragma mark - MLCellSizeManagerCellConfiguration

@interface MLCellSizeManagerCellConfiguration : NSObject

@property (nonatomic, readwrite, strong) id cell;
@property (nonatomic, readwrite, copy) MLCellSizeManagerSizeBlock sizeBlock;
@property (nonatomic, readwrite, copy) NSString * cellClass;
@property (nonatomic, readwrite, copy) NSString * reuseIdentifier;

@end

#pragma mark -

@implementation MLCellSizeManagerCellConfiguration

@end

#pragma mark - MLCellSizeManager

@interface MLCellSizeManager ()

@property (nonatomic, readwrite, strong) NSMutableDictionary * dictionaryOfCellConfigurations;
@property (nonatomic, readwrite, strong) NSCache * cacheOfCellSizes;

@end

#pragma mark -

@implementation MLCellSizeManager

#pragma mark Init

- (instancetype)init {
    if (self = [super init]) {
        _dictionaryOfCellConfigurations = [[NSMutableDictionary alloc] init];
        _cacheOfCellSizes = [[NSCache alloc] init];
        _cellHeightPadding = MLCellSizeManagerDefaultCellHeightPadding;
    }
    
    return self;
}

#pragma mark Accessors

- (void)setOverrideWidth:(CGFloat)overrideWidth {
    if (isgreaterequal(overrideWidth, 0.0f) && islessgreater(overrideWidth, _overrideWidth)) {
        _overrideWidth = overrideWidth;
        
        [self.dictionaryOfCellConfigurations enumerateKeysAndObjectsUsingBlock:^(id key, MLCellSizeManagerCellConfiguration * obj, BOOL *stop) {
            id cell = obj.cell;
            CGRect overideFrame = [cell frame];
            overideFrame.size.width = overrideWidth;
            [cell setFrame:overideFrame];
            [cell setNeedsLayout];
            [cell layoutIfNeeded];
        }];
        
        [self invalidateCellSizeCache];
    }
}

#pragma mark Register

- (void)registerCellClass:(Class <MLCellConfiguration>)cellClass withSizeBlock:(MLCellSizeManagerSizeBlock)sizeBlock {
    NSParameterAssert(cellClass);
    NSParameterAssert(sizeBlock);
    
    NSString * cellClassName = NSStringFromClass(cellClass);
    NSString * reuseIdentifier = [cellClass reuseIdentifier];
    NSString * nibNameOrNil = [cellClass nibName];
    id cell = [self configureOffScreenCellWithCellClassName:cellClassName nibName:nibNameOrNil];
    
    MLCellSizeManagerCellConfiguration * configuration = [[MLCellSizeManagerCellConfiguration alloc] init];
    configuration.cell = cell;
    configuration.cellClass = cellClassName;
    configuration.reuseIdentifier = reuseIdentifier;
    configuration.sizeBlock = sizeBlock;
    
    [self.dictionaryOfCellConfigurations setObject:configuration forKey:cellClassName];
}

#pragma mark Sizes

- (CGSize)cellSizeForObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath {
    return [self cellSizeForObject:anObject atIndexPath:indexPath withReuseIdentifier:nil];
}

- (CGSize)cellSizeForObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath withReuseIdentifier:(NSString *)reuseIdentifier {
    NSParameterAssert(indexPath);
    
    id sizeValue = [self.cacheOfCellSizes objectForKey:indexPath];
    CGSize size = CGSizeZero;
    
    if (!sizeValue) {
        MLCellSizeManagerCellConfiguration * configuration = [self configurationForObject:anObject reuseIdentifier:reuseIdentifier];
        BOOL validSize = NO;
        
        if (configuration.sizeBlock) {
            [configuration.cell prepareForReuse];
            configuration.sizeBlock(configuration.cell, anObject, indexPath);
            UIView * contentView = [configuration.cell contentView];
            
            // Determine size. If your constraints aren't setup correctly
            // this won't work. So make sure you:
            //
            // 1. Set ContentCompressionResistancePriority for all labels
            //    i.e. [self.label setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
            //
            // 2. Set PreferredMaxLayoutWidth for all labels that will have a
            //    auto height. This should equal width of cell minus any buffers on sides.
            //    i.e self.label.preferredMaxLayoutWidth = defaultSize - buffers;
            //
            // 3. Set any imageView's images correctly. Remember if you don't
            //    set a fixed width/height on a UIImageView it will use the 1x
            //    intrinsic size of the image to calculate a constraint. So if your
            //    image isn't sized correctly it will produce an incorrect value.
            //
            size = [contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
            
            // Adding padding for table view cell height
            if ([configuration.cell isKindOfClass:[UITableView class]]) {
                size.height += self.cellHeightPadding;
            }
            
            validSize = YES;
        }
        
        if (validSize) {
            [self.cacheOfCellSizes setObject:[NSValue valueWithCGSize:size] forKey:indexPath];
        }
    }
    else {
        if ([sizeValue isKindOfClass:[NSValue class]]) {
            size = [sizeValue CGSizeValue];
        }
    }
    
    return size;
}

#pragma mark Invalidate

- (void)invalidateCellSizeCache {
    [self.cacheOfCellSizes removeAllObjects];
}

- (void)invalidateCellSizeCacheAtIndexPath:(NSIndexPath *)indexPath {
    NSParameterAssert(indexPath);
    [self.cacheOfCellSizes removeObjectForKey:indexPath];
}

- (void)invalidateCellSizeCacheAtIndexPaths:(NSArray *)arrayOfIndexPaths {
    NSParameterAssert(arrayOfIndexPaths);
    
    for (NSIndexPath * indexPath in arrayOfIndexPaths) {
        [self.cacheOfCellSizes removeObjectForKey:indexPath];
    }
}

#pragma mark Private Methods

- (id)configureOffScreenCellWithCellClassName:(NSString *)className nibName:(NSString *)nibNameOrNil {
    NSParameterAssert(className && className.length);
    
    if ([self.dictionaryOfCellConfigurations objectForKey:className]) {
        [self.dictionaryOfCellConfigurations removeObjectForKey:className];
    }

    id cell = nil;
    
    if (className) {
        NSString * nibName = (nibNameOrNil) ?: className;
        BOOL nibExists = ([[NSBundle mainBundle] pathForResource:nibName ofType:@"nib"] != nil);
        UINib * nib = [UINib nibWithNibName:nibName bundle:nil];
        
        if (nibExists) {
            cell = [[nib instantiateWithOwner:nil options:kNilOptions] objectAtIndex:0];
        }
        else {
            cell = [[NSClassFromString(className) alloc] init];
        }
        
        [cell ml_moveConstraintsToContentView];
    }
    
    if (isgreater(self.overrideWidth, 0.0f)) {
        CGRect overideFrame = [cell frame];
        overideFrame.size.width = self.overrideWidth;
        [cell setFrame:overideFrame];
        [cell setNeedsLayout];
        [cell layoutIfNeeded];
    }
    
    NSAssert(cell != nil, @"Cell not created successfully. Make sure there is a cell with your class name in your project: %@", className);
    return cell;
}

- (MLCellSizeManagerCellConfiguration *)configurationForObject:(id)object reuseIdentifier:(NSString *)reuseIdentifier {
    __block MLCellSizeManagerCellConfiguration* configuration = nil;
    
    if (reuseIdentifier) {
        [self.dictionaryOfCellConfigurations enumerateKeysAndObjectsUsingBlock:^(id key, MLCellSizeManagerCellConfiguration * obj, BOOL *stop) {
            if ([reuseIdentifier isEqualToString:obj.reuseIdentifier]) {
                configuration = obj;
                *stop = YES;
            }
        }];
    }
    
    if (!configuration) {
        configuration = [[self.dictionaryOfCellConfigurations allValues] firstObject];
    }
    
    return configuration;
}

@end
