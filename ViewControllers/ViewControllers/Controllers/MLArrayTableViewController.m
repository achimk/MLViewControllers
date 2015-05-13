//
//  MLArrayTableViewController.m
//  ViewControllers
//
//  Created by Joachim Kret on 29.03.2015.
//  Copyright (c) 2015 Joachim Kret. All rights reserved.
//

#import "MLArrayTableViewController.h"
#import "RZCollectionList.h"
#import "RZBaseCollectionList+MLResultsController.h"
#import "RZArrayCollectionList+MLResultsController.h"
#import "MLTableViewDataSource.h"
#import "MLTableViewCell.h"

#pragma mark - MLArrayTableViewController

@interface MLArrayTableViewController () <MLTableViewDataSourceDelegate>

@property (nonatomic, readwrite, strong) RZArrayCollectionList * arrayResultsController;
@property (nonatomic, readwrite, strong) MLTableViewDataSource * dataSource;

@end

#pragma mark -

@implementation MLArrayTableViewController

#pragma mark View

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [MLTableViewCell registerCellWithTableView:self.tableView];
    self.arrayResultsController = [[RZArrayCollectionList alloc] initWithArray:@[] sectionNameKeyPath:nil];
    self.dataSource = [[MLTableViewDataSource alloc] initWithTableView:self.tableView
                                                     resultsController:self.arrayResultsController
                                                              delegate:self];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                                           target:self
                                                                                           action:@selector(addAction:)];
}

#pragma mark Actions

- (IBAction)addAction:(id)sender {
    [self.arrayResultsController addObject:[NSDate date] toSection:0];
}

#pragma mark MLTableViewDataSourceDelegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MLTableViewCell * cell = [MLTableViewCell cellForTableView:tableView indexPath:indexPath];
    id object = [self.arrayResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = [object description];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditObject:(id)object atIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (UITableViewCellEditingStyleDelete == editingStyle) {
        [self.arrayResultsController removeObjectAtIndexPath:indexPath];
    }
}

@end
