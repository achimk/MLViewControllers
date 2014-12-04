//
//  MLTableViewCell.m
//  ViewControllers
//
//  Created by Joachim Kret on 22.11.2014.
//  Copyright (c) 2014 Joachim Kret. All rights reserved.
//

#import "MLTableViewCell.h"

#define DEFAULT_TABLE_VIEW_CELL_HEIGHT      44.0f

@implementation MLTableViewCell

+ (UITableViewCellStyle)defaultTableViewCellStyle {
    return UITableViewCellStyleDefault;
}

+ (NSString *)defaultTableViewCellIdentifier {
    return NSStringFromClass([self class]);
}

+ (NSString *)defaultTableViewCellNibName {
    return nil;
}

+ (UINib *)defaultNib {
    if ([self defaultTableViewCellNibName]) {
        NSBundle * bundle = [NSBundle bundleForClass:[self class]];
        return [UINib nibWithNibName:[self defaultTableViewCellNibName] bundle:bundle];
    }
    
    return nil;
}

+ (CGFloat)defaultTableViewCellHeight {
    NSString * nibName = [self defaultTableViewCellNibName];
    
    if (nibName) {
        static NSMutableDictionary * dictionaryOfCellHeights = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            dictionaryOfCellHeights = [[NSMutableDictionary alloc] init];
        });
        
        NSNumber * height = [dictionaryOfCellHeights objectForKey:nibName];
        
        if (!height) {
            NSArray * nibObjects = [[self defaultNib] instantiateWithOwner:nil options:nil];
            NSAssert2([nibObjects count] > 0 && [[nibObjects objectAtIndex:0] isKindOfClass:[self class]], @"Nib '%@' doesn't appear to contain a valid %@", [self defaultTableViewCellNibName], [self class]);
            UITableViewCell * cell = (UITableViewCell *)[nibObjects objectAtIndex:0];
            height = @(cell.bounds.size.height);
            [dictionaryOfCellHeights setObject:height forKey:nibName];
        }
        
        return height.floatValue;
    }
    
    return DEFAULT_TABLE_VIEW_CELL_HEIGHT;
}

+ (void)registerCellWithTableView:(UITableView *)tableView {
    NSParameterAssert(tableView);
    
    if ([self defaultTableViewCellNibName]) {
        [tableView registerNib:[self defaultNib] forCellReuseIdentifier:[self defaultTableViewCellNibName]];
    }
    else if ([self defaultTableViewCellIdentifier]) {
        [tableView registerClass:[self class] forCellReuseIdentifier:[self defaultTableViewCellIdentifier]];
    }
    else {
        NSAssert(NO, @"Can't register cell '%@' without nib name or cell identifier", [self class]);
    }
}

+ (id)cellForTableView:(UITableView *)tableView {
    return [self cellForTableView:tableView indexPath:nil];
}

+ (id)cellForTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath {
    NSParameterAssert(tableView);
    
    NSString * cellIdentifier = ([self defaultTableViewCellNibName]) ? [self defaultTableViewCellNibName] : [self defaultTableViewCellIdentifier];
    UITableViewCell * cell = nil;
    
    if (cellIdentifier) {
        if (indexPath) {
            cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
        }
        else {
            cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        }
    }
    else {
        NSAssert(NO, @"Can't dequeue cell '%@' without nib name or cell identifier", [self class]);
    }
    
    return cell;
}

#pragma mark Dynamic Resizing

+ (CGSize)cellSizeForData:(id)dataObject tableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath {
    NSParameterAssert(tableView);
    NSParameterAssert(indexPath);
    
    static NSMutableArray * arrayOfCells = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        arrayOfCells = [[NSMutableArray alloc] init];
    });
    
    MLTableViewCell * cell = nil;
    
    // dequeue cached cell
    for (MLTableViewCell * tempCell in arrayOfCells) {
        if ([cell isKindOfClass:[[self class] class]]) {
            cell = tempCell;
            break;
        }
    }
    
    // create and cache cell
    if (!cell) {
        if ([[self class] defaultTableViewCellNibName]) {
            NSArray * nibObjects = [[self defaultNib] instantiateWithOwner:nil options:nil];
            NSAssert2([nibObjects count] > 0 && [[nibObjects objectAtIndex:0] isKindOfClass:[self class]], @"Nib '%@' doesn't appear to contain a valid %@", [self defaultTableViewCellNibName], [self class]);
            cell = (MLTableViewCell *)[nibObjects objectAtIndex:0];
        }
        else if ([[self class] defaultTableViewCellIdentifier]) {
            cell = [[[self class] alloc] initWithStyle:[self defaultTableViewCellStyle] reuseIdentifier:[self defaultTableViewCellIdentifier]];
            cell.frame = CGRectMake(0.0f, 0.0f, tableView.bounds.size.width, [self defaultTableViewCellHeight]);
        }
        else {
            NSAssert(NO, @"Can't create cell without nib name or identifier");
            return CGSizeZero;
        }
        
        [arrayOfCells addObject:cell];
    }
    
    // configure cell with data
    [cell configureForData:dataObject tableView:tableView indexPath:indexPath type:MLTableViewCellConfigureDynamicResize];
    
    // Make sure the constraints have been added to this cell, since it may have just been created from scratch
    [cell setNeedsUpdateConstraints];
    [cell updateConstraintsIfNeeded];
    
    // The cell's width must be set to the same size it will end up at once it is in the table view.
    // This is important so that we'll get the correct height for different table view widths, since our cell's
    // height depends on its width due to the multi-line UILabel word wrapping. Don't need to do this above in
    // -[tableView:cellForRowAtIndexPath:] because it happens automatically when the cell is used in the table view.
    cell.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(tableView.bounds), CGRectGetHeight(tableView.bounds));
    
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
    size.width = MAX(tableView.bounds.size.width, size.width);

    // Add an extra point to the height to account for the cell separator, which is added between the bottom
    // of the cell's contentView and the bottom of the table view cell.
    if (SYSTEM_VERSION_LESS_THAN(@"8.0")) {
        size.height += 1.0f;
    }
    
    return size;
}


#pragma mark Init

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:[[self class] defaultTableViewCellStyle] reuseIdentifier:reuseIdentifier]) {
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

- (void)configureForData:(id)dataObject tableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath {
    [self configureForData:dataObject
                 tableView:tableView
                 indexPath:indexPath
                      type:MLTableViewCellConfigureDefault];
}

- (void)configureForData:(id)dataObject tableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath type:(MLTableViewCellConfigureType)type {
    METHOD_MUST_BE_OVERRIDDEN;
}

@end
