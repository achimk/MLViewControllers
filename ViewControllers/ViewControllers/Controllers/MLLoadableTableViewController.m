//
//  MLLoadableTableViewController.m
//  ViewControllers
//
//  Created by Joachim Kret on 24.03.2015.
//  Copyright (c) 2015 Joachim Kret. All rights reserved.
//

#import "MLLoadableTableViewController.h"
#import "MLTableViewDataSource.h"
#import "MLTableViewCell.h"
#import "MLLoadingTableViewCell.h"

#pragma mark - MLLoadableTableViewController

@interface MLLoadableTableViewController () <MLTableViewLoadingDataSourceDelegate>

@property (nonatomic, readwrite, strong) MLTableViewDataSource * dataSource;

@end

#pragma mark -

@implementation MLLoadableTableViewController

#pragma mark View

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.reloadOnAppearsFirstTime = NO;
    self.dataSource = [[MLTableViewDataSource alloc] initWithTableView:self.tableView
                                                     resultsController:self.resultsController
                                                              delegate:self];
    self.dataSource.animateTableChanges = YES;
    
    [MLTableViewCell registerCellWithTableView:self.tableView];
    [MLLoadingTableViewCell registerCellWithTableView:self.tableView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if ([self.loadableContent.currentState isEqualToString:MLContentStateInitial]) {
        [self.loadableContent loadContent];
    }
}

#pragma mark Reload Data

- (void)reloadData {
    [self.dataSource reloadData];
}

#pragma mark MLTableViewDataSourceDelegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MLTableViewCell * cell = [MLTableViewCell cellForTableView:tableView indexPath:indexPath];
    id object = [self.resultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = [object description];
    return cell;
}

#pragma mark MLTableViewLoadingDataSourceDelegate

- (UITableViewCell *)tableView:(UITableView *)tableView loadingCellAtIndexPath:(NSIndexPath *)indexPath {
    MLLoadingTableViewCell * cell = [MLLoadingTableViewCell cellForTableView:tableView indexPath:indexPath];
    [self.loadableContent pageContent];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView shouldShowLoadingCellAtIndexPath:(NSIndexPath *)indexPath {
    BOOL isPagingType = (self.loadableContent.type == MLLoadableContentTypePaging);
    BOOL isLoaded = self.loadableContent.isLoaded;
    BOOL isPaging = self.loadableContent.isPaging;
    BOOL showLoadingCell =  isPagingType && (isLoaded || isPaging);
    
    NSLog(@"-> %@: show loading cell: %@ for state: %@", NSStringFromClass([self class]), @(showLoadingCell), self.loadableContent.currentState);
    
    return showLoadingCell;
}

@end
