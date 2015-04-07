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

- (void)configureWithObject:(id)anObject indexPath:(NSIndexPath *)indexPath {
    [self configureWithObject:anObject indexPath:indexPath type:MLCellConfigurationTypeDefault];
}

- (void)configureWithObject:(id)anObject indexPath:(NSIndexPath *)indexPath type:(MLCellConfigurationType)type {
    // Subclasses should override this method.
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

#pragma mark - MLCollectionViewCell (MLCellSize)

@implementation MLCollectionViewCell (MLCellSize)

+ (CGSize)cellSize {
    NSString * nibName = [self nibName];
    
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
            UICollectionView * cell = (UICollectionView *)nibObjects[0];
            sizeValue = [NSValue valueWithCGSize:cell.bounds.size];
            [dictionaryOfCellSizes setObject:sizeValue forKey:nibName];
        }
    }
    
    return (sizeValue) ? sizeValue.CGSizeValue : CGSizeZero;
}

+ (CGSize)cellSizeWithObject:(id)anObject collectionView:(UICollectionView *)collectionView indexPath:(NSIndexPath *)indexPath {
    NSParameterAssert(collectionView);
    NSParameterAssert(indexPath);
    
    static NSMutableDictionary * dictionaryOfCells = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dictionaryOfCells = [[NSMutableDictionary alloc] init];
    });
    
    // dequeue cached cell
    NSString * className = NSStringFromClass([self class]);
    MLCollectionViewCell * cell = dictionaryOfCells[className];

    // create and cache cell
    if (!cell) {
        if ([[self class] nibName]) {
            NSBundle * bundle = [NSBundle bundleForClass:[self class]];
            UINib * nib = [UINib nibWithNibName:[self nibName] bundle:bundle];
            NSArray * nibObjects = [nib instantiateWithOwner:nil options:nil];
            NSAssert2([nibObjects count] > 0 && [[nibObjects objectAtIndex:0] isKindOfClass:[self class]], @"Nib '%@' doesn't appear to contain a valid %@", [self nibName], [self class]);
            cell = (MLCollectionViewCell *)[nibObjects objectAtIndex:0];
        }
        else {
            cell = [[[self class] alloc] initWithFrame:CGRectMake(0.0f, 0.0f, collectionView.bounds.size.width, 100.0f)];
        }
        
        [dictionaryOfCells setObject:cell forKey:className];
    }
    else {
        [cell prepareForReuse];
    }
    
    // configure cell with data
    [cell configureWithObject:anObject indexPath:indexPath type:MLCellConfigurationTypeSize];
    
    // Make sure the constraints have been added to this cell, since it may have just been created from scratch
    [cell setNeedsUpdateConstraints];
    [cell updateConstraintsIfNeeded];
    
    // The cell's width must be set to the same size it will end up at once it is in the table view.
    // This is important so that we'll get the correct height for different table view widths, since our cell's
    // height depends on its width due to the multi-line UILabel word wrapping. Don't need to do this above in
    // -[tableView:cellForRowAtIndexPath:] because it happens automatically when the cell is used in the table view.
    cell.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(collectionView.bounds), CGRectGetHeight(collectionView.bounds));
    
    // Do the layout pass on the cell, which will calculate the frames for all the views based on the constraints
    // (Note that the preferredMaxLayoutWidth is set on multi-line UILabels inside the -[layoutSubviews] method
    // in the UITableViewCell subclass
    [cell setNeedsLayout];
    [cell layoutIfNeeded];
    
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
    CGSize size = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    
    // Return which size is bigger since systemLayoutFittingSize will return
    // the smallest size fitting that fits.
    size.width = MAX(collectionView.bounds.size.width, size.width);
    
    return size;
}

@end
