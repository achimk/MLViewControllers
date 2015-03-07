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

#pragma mark Dynamic Resizing

+ (CGSize)cellSizeForData:(id)dataObject collectionView:(UICollectionView *)collectionView indexPath:(NSIndexPath *)indexPath {
    NSParameterAssert(collectionView);
    NSParameterAssert(indexPath);
    
    static NSMutableArray * arrayOfCells = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        arrayOfCells = [[NSMutableArray alloc] init];
    });
    
    MLCollectionViewCell * cell = nil;
    
    // dequeue cached cell
    for (MLCollectionViewCell * tempCell in arrayOfCells) {
        if ([cell isKindOfClass:[[self class] class]]) {
            cell = tempCell;
            break;
        }
    }
    
    // create and cache cell
    if (!cell) {
        if ([[self class] defaultCollectionViewCellNibName]) {
            NSArray * nibObjects = [[self defaultNib] instantiateWithOwner:nil options:nil];
            NSAssert2([nibObjects count] > 0 && [[nibObjects objectAtIndex:0] isKindOfClass:[self class]], @"Nib '%@' doesn't appear to contain a valid %@", [self defaultCollectionViewCellNibName], [self class]);
            cell = (MLCollectionViewCell *)[nibObjects objectAtIndex:0];
        }
        else if ([[self class] defaultCollectionViewCellIdentifier]) {
            cell = [[[self class] alloc] initWithFrame:CGRectMake(0.0f, 0.0f, collectionView.bounds.size.width, 100.0f)];
        }
        else {
            NSAssert(NO, @"Can't create cell without nib name or identifier");
            return CGSizeZero;
        }
        
        [arrayOfCells addObject:cell];
    }
    
    // configure cell with data
    [cell configureForData:dataObject collectionView:collectionView indexPath:indexPath type:MLCollectionViewCellConfigureDynamicResize];
    
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
    [self configureForData:dataObject
            collectionView:collectionView
                 indexPath:indexPath
                      type:MLCollectionViewCellConfigureDefault];
}

- (void)configureForData:(id)dataObject collectionView:(UICollectionView *)collectionView indexPath:(NSIndexPath *)indexPath type:(MLCollectionViewCellConfigureType)type {
    METHOD_MUST_BE_OVERRIDDEN;
}

@end
