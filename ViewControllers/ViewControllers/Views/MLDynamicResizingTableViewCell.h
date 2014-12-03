//
//  MLDynamicResizingTableViewCell.h
//  ViewControllers
//
//  Created by Joachim Kret on 26/11/14.
//  Copyright (c) 2014 Joachim Kret. All rights reserved.
//

#import "MLTableViewCell.h"

@protocol MLDynamicResizingTableViewCellProtocol <MLTableViewCellProtocol>

@required
+ (CGSize)cellSizeForData:(id)dataObject tableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath;

@end

@interface MLDynamicResizingTableViewCell : MLTableViewCell <MLTableViewCellProtocol>

@end
