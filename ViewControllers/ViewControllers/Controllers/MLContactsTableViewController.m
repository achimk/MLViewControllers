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

#define IGNORE_CACHE        1
#define USE_SIZE_MANAGER    0

#pragma mark - MLContactsTableViewController

@interface MLContactsTableViewController ()

@property (nonatomic, readwrite, strong) NSArray * arrayOfContacts;
@property (nonatomic, readwrite, strong) NSCache * cacheOfCellHeights;
@property (nonatomic, readwrite, strong) MLCellSizeManager * sizeManager;

@end

#pragma mark -

@implementation MLContactsTableViewController

#pragma mark Init

- (void)finishInitialize {
    [super finishInitialize];
    
    _cacheOfCellHeights = [[NSCache alloc] init];
    _sizeManager = [[MLCellSizeManager alloc] init];
}

#pragma mark View

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self arrayOfContacts];
    
    [MLContactTableViewCell registerCellWithTableView:self.tableView];
    [self.sizeManager registerCellClass:[MLContactTableViewCell class] withSizeBlock:^(id cell, id anObject, NSIndexPath * indexPath) {
        [cell configureWithObject:anObject indexPath:indexPath];
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
    [cell configureWithObject:[self.arrayOfContacts objectAtIndex:indexPath.row] indexPath:indexPath];
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
#if USE_SIZE_MANAGER
    [self.sizeManager invalidateCellSizeCache];
#else
#if !IGNORE_CACHE
    [self.cacheOfCellHeights removeAllObjects];
#endif
#endif
}

#pragma mark Private Methods

- (id)jsonObjectFromFilename:(NSString *)filename {
    NSParameterAssert(filename);
    id path = [[NSBundle bundleForClass:[self class]] URLForResource:filename withExtension:@"json"];
    id json = [NSData dataWithContentsOfURL:path];
    return [NSJSONSerialization JSONObjectWithData:json options:kNilOptions error:nil];
}

- (CGFloat)cacheCellHeightForData:(id)data tableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath {
#if USE_SIZE_MANAGER
    CGSize size = [self.sizeManager cellSizeForObject:data atIndexPath:indexPath];
    return size.height;
#else
    NSNumber * height = [self.cacheOfCellHeights objectForKey:@(indexPath.row)];
    
    if (!height) {
        CGSize size = [MLContactTableViewCell cellSizeWithObject:data
                                                       tableView:tableView
                                                       indexPath:indexPath];
        height = @(size.height);
#if !IGNORE_CACHE
        [self.cacheOfCellHeights setObject:height forKey:@(indexPath.row)];
#endif
    }
    
    return (height) ? height.floatValue : 0.0f;
#endif
}

@end
