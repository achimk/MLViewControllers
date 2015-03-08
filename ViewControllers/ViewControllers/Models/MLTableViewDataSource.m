//
//  MLTableViewDataSource.m
//  ViewControllers
//
//  Created by Joachim Kret on 07.03.2015.
//  Copyright (c) 2015 Joachim Kret. All rights reserved.
//

#import "MLTableViewDataSource.h"

@interface MLTableViewDataSource ()

@property (nonatomic, readwrite, weak) UITableView * tableView;

@end

@implementation MLTableViewDataSource

- (instancetype)init {
    METHOD_USE_DESIGNATED_INIT;
    return nil;
}

- (instancetype)initWithTableView:(UITableView *)tableView resultsController:(id <MLResultsController>)resultsController delegate:(id <MLTableViewDataSourceDelegate>)delegate {
    NSParameterAssert(tableView);
    
    if (self = [super init]) {
        self.tableView = tableView;
        self.tableView.dataSource = self;
        self.resultsController = resultsController;
        self.delegate = delegate;
    }
    
    return self;
}

#pragma mark UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    id object = [self.resultsController objectAtIndexPath:indexPath];
    return [self.delegate tableView:self.tableView cellForObject:object atIndexPath:indexPath];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.resultsController.sections count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id <MLResultsSectionInfo> sectionInfo = [self.resultsController.sections objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

@end
