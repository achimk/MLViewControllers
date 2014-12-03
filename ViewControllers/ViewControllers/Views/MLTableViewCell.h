//
//  MLTableViewCell.h
//  ViewControllers
//
//  Created by Joachim Kret on 22.11.2014.
//  Copyright (c) 2014 Joachim Kret. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MLTableViewCellProtocol <NSObject>

@required
- (void)configureForData:(id)dataObject tableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath;

@end

@interface MLTableViewCell : UITableViewCell <MLTableViewCellProtocol>

+ (UITableViewCellStyle)defaultTableViewCellStyle;
+ (NSString *)defaultTableViewCellIdentifier;
+ (NSString *)defaultTableViewCellNibName;
+ (UINib *)defaultNib;
+ (CGFloat)defaultTableViewCellHeight;

+ (void)registerCellWithTableView:(UITableView *)tableView;
+ (id)cellForTableView:(UITableView *)tableView;
+ (id)cellForTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath;

@end

@interface MLTableViewCell (MLSubclassOnly)

- (void)finishInitialize;

@end