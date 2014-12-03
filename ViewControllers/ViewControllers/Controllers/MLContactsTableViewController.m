//
//  MLContactsTableViewController.m
//  ViewControllers
//
//  Created by Joachim Kret on 26/11/14.
//  Copyright (c) 2014 Joachim Kret. All rights reserved.
//

#import "MLContactsTableViewController.h"

#import "MLCustomTableViewCell.h"

#pragma mark - MLContactsTableViewController

@interface MLContactsTableViewController ()

@property (nonatomic, readwrite, strong) NSArray * arrayOfContacts;

- (id)jsonObjectFromFilename:(NSString *)filename;

@end

#pragma mark -

@implementation MLContactsTableViewController

#pragma mark View

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self arrayOfContacts];
    
    [MLCustomTableViewCell registerCellWithTableView:self.tableView];
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
    CGSize size = [[MLCustomTableViewCell class] cellSizeForData:[self.arrayOfContacts objectAtIndex:indexPath.row] tableView:tableView indexPath:indexPath];
    
    return size.height;
}

#pragma mark UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MLCustomTableViewCell * cell = [MLCustomTableViewCell cellForTableView:tableView indexPath:indexPath];
    [cell configureForData:[self.arrayOfContacts objectAtIndex:indexPath.row] tableView:tableView indexPath:indexPath];
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.arrayOfContacts.count;
}

#pragma mark Private

- (id)jsonObjectFromFilename:(NSString *)filename {
    NSParameterAssert(filename);
    id path = [[NSBundle bundleForClass:[self class]] URLForResource:filename withExtension:@"json"];
    id json = [NSData dataWithContentsOfURL:path];
    return [NSJSONSerialization JSONObjectWithData:json options:kNilOptions error:nil];
}

@end
