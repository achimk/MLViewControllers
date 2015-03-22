//
//  MLLoadingArrayDataTableViewController.m
//  ViewControllers
//
//  Created by Joachim Kret on 22.03.2015.
//  Copyright (c) 2015 Joachim Kret. All rights reserved.
//

#import "MLLoadingArrayDataTableViewController.h"
#import "MLLoadableContentViewModel.h"
#import "MLTableViewDataSource.h"
#import "MLCollectionListController.h"
#import "RZCollectionList.h"
#import "MLTableViewCell.h"
#import "MLLoadingTableViewCell.h"

#define LOAD_TIME_INTERVAL      1.0f
#define NUMBER_OF_LOAD_ITEMS    5

#pragma mark - MLLoadingArrayDataTableViewController

@interface MLLoadingArrayDataTableViewController () <MLLoadableContentDelegate, MLTableViewLoadingDataSourceDelegate>

@property (nonatomic, readwrite, strong) MLLoadableContentViewModel * viewModel;
@property (nonatomic, readwrite, strong) MLTableViewDataSource * dataSource;

@end

#pragma mark -

@implementation MLLoadingArrayDataTableViewController

#pragma mark View

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // init loadable content view model
    self.viewModel = [[MLLoadableContentViewModel alloc] init];
    self.viewModel.delegate = self;
    
    // init resource controller and data source
    RZArrayCollectionList * collectionList = [[RZArrayCollectionList alloc] initWithArray:@[] sectionNameKeyPath:nil];
    MLCollectionListController * resultsController = [[MLCollectionListController alloc] initWithCollectionList:collectionList];
    
    self.dataSource = [[MLTableViewDataSource alloc] initWithTableView:self.tableView
                                                     resultsController:resultsController
                                                              delegate:self];
    self.dataSource.animateTableChanges = NO;
    
    // register reusable cells
    [MLTableViewCell registerCellWithTableView:self.tableView];
    [MLLoadingTableViewCell registerCellWithTableView:self.tableView];
    
    // refresh button item
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                                                           target:self
                                                                                           action:@selector(refreshAction:)];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.appearsFirstTime) {
        [self.viewModel loadContent];
    }
}

#pragma mark Accessors

- (RZArrayCollectionList *)collectionList {
    return (self.dataSource && [self.dataSource.resultsController isKindOfClass:[MLCollectionListController class]]) ? [(MLCollectionListController *)self.dataSource.resultsController collectionList] : nil;
}

#pragma mark Actions

- (IBAction)refreshAction:(id)sender {
    [self.viewModel refreshContent];
}

#pragma mark MLLoadableContentDelegate

- (void)loadableContent:(MLLoadableContentViewModel *)model loadDataWithLoadToken:(MLLoadToken *)loadToken {
    BOOL refreshItems = ([model.currentState isEqualToString:MLContentStateRefreshing]);
    __weak typeof(self)weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(LOAD_TIME_INTERVAL * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (MLLoadTokenStateIgnore == loadToken.state) {
            return;
        }
        
        [loadToken success:@(NUMBER_OF_LOAD_ITEMS)];
        
        RZArrayCollectionList * collectionList = [weakSelf collectionList];
        [collectionList beginUpdates];
        
        if (refreshItems) {
            [collectionList removeAllObjects];
        }
        
        for (NSUInteger i = 0; i < NUMBER_OF_LOAD_ITEMS; i++) {
            [collectionList addObject:[NSDate date] toSection:0];
        }
        
        [collectionList endUpdates];
    });
}

#pragma mark MLTableViewDataSourceDelegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForObject:(id)object atIndexPath:(NSIndexPath *)indexPath {
    MLTableViewCell * cell = [MLTableViewCell cellForTableView:tableView indexPath:indexPath];
    cell.textLabel.text = [object description];
    return cell;
}

#pragma mark MLTableViewLoadingDataSourceDelegate

- (UITableViewCell *)tableView:(UITableView *)tableView loadingCellAtIndexPath:(NSIndexPath *)indexPath {
    MLLoadingTableViewCell * cell = [MLLoadingTableViewCell cellForTableView:tableView indexPath:indexPath];
    [self.viewModel pageContent];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView shouldShowLoadingCellAtIndexPath:(NSIndexPath *)indexPath {
    NSString * currentState = self.viewModel.currentState;
    
    return [currentState isEqualToString:MLContentStateLoaded];
}

@end
