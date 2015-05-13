//
//  MLFetchedTableViewController.m
//  ViewControllers
//
//  Created by Joachim Kret on 29.03.2015.
//  Copyright (c) 2015 Joachim Kret. All rights reserved.
//

#import "MLFetchedTableViewController.h"
#import "MLFetchedResultsController.h"
#import "MLTableViewDataSource.h"
#import "MLTableViewCell.h"
#import "MLEventEntity.h"

#pragma mark - MLFetchedTableViewController

@interface MLFetchedTableViewController () <MLTableViewDataSourceDelegate>

@property (nonatomic, readwrite, strong) MLFetchedResultsController * fetchedResultsController;
@property (nonatomic, readwrite, strong) MLTableViewDataSource * dataSource;

@end

#pragma mark -

@implementation MLFetchedTableViewController

#pragma mark Dealloc

- (void)dealloc {
    [[MLCoreDataStack defaultStack] saveWithBlock:^(NSManagedObjectContext *context) {
        [MLEventEntity ml_deleteAllInContext:context];
    }];
}

#pragma mark View

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [MLTableViewCell registerCellWithTableView:self.tableView];
    
    NSPredicate * predicate = nil;
    NSSortDescriptor * sort = [NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:YES];
    NSFetchRequest * fetchRequest = [MLEventEntity ml_requestWithPredicate:predicate withSortDescriptor:sort];
    NSManagedObjectContext * context = [[MLCoreDataStack defaultStack] managedObjectContext];
    
    self.fetchedResultsController = [[MLFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                        managedObjectContext:context
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:nil];
    
    self.dataSource = [[MLTableViewDataSource alloc] initWithTableView:self.tableView
                                                     resultsController:self.fetchedResultsController
                                                              delegate:self];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                                           target:self
                                                                                           action:@selector(addAction:)];
}

#pragma mark Actions

- (IBAction)addAction:(id)sender {
    [[MLCoreDataStack defaultStack] saveWithBlock:^(NSManagedObjectContext *context) {
        MLEventEntity * event = [MLEventEntity ml_createInContext:context];
        event.timestamp = [NSDate date];
    }];
}

#pragma mark MLTableViewDataSourceDelegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MLTableViewCell * cell = [MLTableViewCell cellForTableView:tableView indexPath:indexPath];
    MLEventEntity * event = (MLEventEntity *)[self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = [event.timestamp description];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditObject:(id)object atIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (UITableViewCellEditingStyleDelete == editingStyle) {
        MLEventEntity * event = [self.fetchedResultsController objectAtIndexPath:indexPath];
        NSManagedObjectID * objectID = [event objectID];
        [[MLCoreDataStack defaultStack] saveWithBlock:^(NSManagedObjectContext *context) {
            NSManagedObject * object = [context objectRegisteredForID:objectID];
            [context deleteObject:object];
        }];
    }
}

@end
