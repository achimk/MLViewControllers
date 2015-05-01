//
//  MLContactsTableViewController.m
//  ViewControllers
//
//  Created by Joachim Kret on 26/11/14.
//  Copyright (c) 2014 Joachim Kret. All rights reserved.
//

#import "MLContactsTableViewController.h"
#import "MLContactTableViewCell.h"
#import "MLCellSizeManager.h"

#pragma mark - MLContactsTableViewController

@interface MLContactsTableViewController ()

@property (nonatomic, readwrite, strong) NSArray * arrayOfContacts;
@property (nonatomic, readwrite, strong) MLCellSizeManager * sizeManager;

@end

#pragma mark -

@implementation MLContactsTableViewController

#pragma mark Init

- (void)finishInitialize {
    [super finishInitialize];
    
    _sizeManager = [[MLCellSizeManager alloc] init];
}

#pragma mark View

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self arrayOfContacts];
    
    [MLContactTableViewCell registerCellWithTableView:self.tableView];
    [self.sizeManager registerCellClass:[MLContactTableViewCell class] withSizeBlock:^(id cell, id anObject, NSIndexPath * indexPath) {
        [cell configureWithObject:anObject context:indexPath];
    }];
}

#pragma mark Accessors

- (NSArray *)arrayOfContacts {
    if (!_arrayOfContacts) {
        _arrayOfContacts = [self jsonObjectFromFilename:@"Contacts"];
    }
    
    return _arrayOfContacts;
}

#pragma mark UITableViewDelegate

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self cacheCellHeightForData:[self.arrayOfContacts objectAtIndex:indexPath.row]
                              tableView:tableView
                              indexPath:indexPath];
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100.0f;
}

#pragma mark UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MLContactTableViewCell * cell = [MLContactTableViewCell cellForTableView:tableView indexPath:indexPath];
    [cell configureWithObject:[self.arrayOfContacts objectAtIndex:indexPath.row] context:indexPath];
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.arrayOfContacts.count;
}

#pragma mark Rotation

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    self.sizeManager.overrideWidth = self.view.bounds.size.height;
}

#pragma mark Private Methods

- (id)jsonObjectFromFilename:(NSString *)filename {
    NSParameterAssert(filename);
    id path = [[NSBundle bundleForClass:[self class]] URLForResource:filename withExtension:@"json"];
    id json = [NSData dataWithContentsOfURL:path];
    return [NSJSONSerialization JSONObjectWithData:json options:kNilOptions error:nil];
}

- (CGFloat)cacheCellHeightForData:(id)data tableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath {
    CGSize size = [self.sizeManager cellSizeForObject:data atIndexPath:indexPath];
    return size.height;
}

@end
