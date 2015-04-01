//
//  MLTableViewCell.h
//  ViewControllers
//
//  Created by Joachim Kret on 22.11.2014.
//  Copyright (c) 2014 Joachim Kret. All rights reserved.
//

#import <UIKit/UIKit.h>

// Cell configuration types
typedef NS_ENUM(NSUInteger, MLTableViewCellConfigureType) {
    MLTableViewCellConfigureDefault,        // Default type when cell needs to be populated with all resources.
    MLTableViewCellConfigureDynamicResize   // Dynamic resize type, called from cellSizeForData:tableView:indexPath: to compute cell size.
};

@protocol MLTableViewCellProtocol <NSObject>

@required
// Default cell size. Returns size of cell when loaded from nib file otherwise CGSizeZero.
+ (CGSize)cellSize;

// Dynamic cell size. Populate with data and compute the size by autolayout.
+ (CGSize)cellSizeForData:(id)dataObject tableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath;

// Configure cell for data. Default behaviour when dynamic cell size is not used.
- (void)configureForData:(id)dataObject tableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath;

// Configure cell for data and define configure type. Used to compute dynamic cell size and prevent to load uneccessary resources (eg. big images or networking calls).
- (void)configureForData:(id)dataObject tableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath type:(MLTableViewCellConfigureType)type;

@end

@interface MLTableViewCell : UITableViewCell <MLTableViewCellProtocol>

// Register cell with table view.
+ (void)registerCellWithTableView:(UITableView *)tableView;

// Dequeue registered cell for table view.
+ (id)cellForTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath;

// Corresponding table view found in responder chain
- (UITableView *)tableView;

// Corresponding view controller found in responder chain
- (UIViewController *)viewController;

@end

@interface MLTableViewCell (MLSubclassOnly)

// Define default cell style when registered from class.
+ (UITableViewCellStyle)defaultTableViewCellStyle;

// Define default cell identifier. Used for register and dequeue class cell from table view.
+ (NSString *)defaultTableViewCellIdentifier;

// Define default cell nib name. Used for register and dequeue nib cell from table view.
+ (NSString *)defaultTableViewCellNibName;

// Common initializer for initWithStyle:reuseIdentifier: and awakeFromNib. You don't need to call super implementation.
- (void)finishInitialize;

@end