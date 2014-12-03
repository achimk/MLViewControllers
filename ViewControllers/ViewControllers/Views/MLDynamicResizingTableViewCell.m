//
//  MLDynamicResizingTableViewCell.m
//  ViewControllers
//
//  Created by Joachim Kret on 26/11/14.
//  Copyright (c) 2014 Joachim Kret. All rights reserved.
//

#import "MLDynamicResizingTableViewCell.h"

@implementation MLDynamicResizingTableViewCell

#pragma mark Sizing

+ (CGSize)cellSizeForData:(id)dataObject tableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath {
    NSParameterAssert(tableView);
    NSParameterAssert(indexPath);
    
    static NSMutableArray * arrayOfCells = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        arrayOfCells = [[NSMutableArray alloc] init];
    });
    
    MLDynamicResizingTableViewCell * cell = nil;
    
    // dequeue cached cell
    for (MLDynamicResizingTableViewCell * tempCell in arrayOfCells) {
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
            cell = (MLDynamicResizingTableViewCell *)[nibObjects objectAtIndex:0];
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
    [cell configureForData:dataObject tableView:tableView indexPath:indexPath];
    
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
    
    return size;
}

@end
