//
//  MLArrayDataTableViewController.m
//  ViewControllers
//
//  Created by Joachim Kret on 09.03.2015.
//  Copyright (c) 2015 Joachim Kret. All rights reserved.
//

#import "MLArrayDataTableViewController.h"
#import "MLTableViewDataSource.h"
#import "MLCollectionListController.h"
#import "RZCollectionList.h"
#import "MLTableViewCell.h"

#pragma mark - MLArrayDataTableViewController

@interface MLArrayDataTableViewController () <MLTableViewDataSourceDelegate>

@property (nonatomic, readwrite, strong) MLTableViewDataSource * dataSource;

@end

#pragma mark -

@implementation MLArrayDataTableViewController

#pragma mark View

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [MLTableViewCell registerCellWithTableView:self.tableView];
    
    RZArrayCollectionList * collectionList = [[RZArrayCollectionList alloc] initWithArray:@[] sectionNameKeyPath:nil];
    MLCollectionListController * resultsController = [[MLCollectionListController alloc] initWithCollectionList:collectionList];
    
    self.dataSource = [[MLTableViewDataSource alloc] initWithTableView:self.tableView
                                                     resultsController:resultsController
                                                              delegate:self];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                                           target:self
                                                                                           action:@selector(addAction:)];
}

#pragma mark Accessors

- (RZArrayCollectionList *)collectionList {
    return (self.dataSource && [self.dataSource.resultsController isKindOfClass:[MLCollectionListController class]]) ? [(MLCollectionListController *)self.dataSource.resultsController collectionList] : nil;
}

#pragma mark Actions

- (IBAction)addAction:(id)sender {
    [self.collectionList addObject:[NSDate date] toSection:0];
}

#pragma mark MLTableViewDataSourceDelegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForObject:(id)object atIndexPath:(NSIndexPath *)indexPath {
    MLTableViewCell * cell = [MLTableViewCell cellForTableView:tableView indexPath:indexPath];
    cell.textLabel.text = [object description];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditObject:(id)object atIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (UITableViewCellEditingStyleDelete == editingStyle) {
        [self.collectionList removeObjectAtIndexPath:indexPath];
    }
}

@end
