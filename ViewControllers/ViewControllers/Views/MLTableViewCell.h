//
//  MLTableViewCell.h
//  ViewControllers
//
//  Created by Joachim Kret on 22.11.2014.
//  Copyright (c) 2014 Joachim Kret. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MLCellConfiguration.h"

@interface MLTableViewCell : UITableViewCell <MLCellConfiguration>

// Register cell with table view.
+ (void)registerCellWithTableView:(UITableView *)tableView;

// Dequeue registered cell for table view.
+ (id)cellForTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath;

// Corresponding table view found in responder chain.
- (UITableView *)tableView;

// Corresponding view controller found in responder chain.
- (UIViewController *)viewController;

@end

@interface MLTableViewCell (MLCellSize)

// Default cell size. Returns size of cell when loaded from nib file otherwise CGSizeZero.
+ (CGSize)cellSize;

// Dynamic cell size. Populate with data and compute the size by autolayout.
+ (CGSize)cellSizeWithObject:(id)anObject tableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath;

@end

@interface MLTableViewCell (MLSubclassOnly)

// Define default cell style when registered from class.
+ (UITableViewCellStyle)defaultTableViewCellStyle;

// Common initializer for initWithStyle:reuseIdentifier: and awakeFromNib. You don't need to call super implementation.
- (void)finishInitialize;

@end