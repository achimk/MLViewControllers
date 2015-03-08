//
//  MLTableViewDataSource.h
//  ViewControllers
//
//  Created by Joachim Kret on 07.03.2015.
//  Copyright (c) 2015 Joachim Kret. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MLResultsControllerProtocol.h"

@protocol MLTableViewDataSourceDelegate <NSObject>

@required
- (UITableViewCell *)tableView:(UITableView *)tableView cellForObject:(id)object atIndexPath:(NSIndexPath *)indexPath;

@end

@interface MLTableViewDataSource : NSObject <UITableViewDataSource>

@property (nonatomic, readonly, weak) UITableView * tableView;
@property (nonatomic, readwrite, strong) id <MLResultsController> resultsController;
@property (nonatomic, readwrite, weak) id <MLTableViewDataSourceDelegate> delegate;

- (instancetype)initWithTableView:(UITableView *)tableView resultsController:(id <MLResultsController>)resultsController delegate:(id <MLTableViewDataSourceDelegate>)delegate;

@end
