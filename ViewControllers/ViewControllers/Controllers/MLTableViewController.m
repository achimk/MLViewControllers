//
//  MLTableViewController.m
//  ViewControllers
//
//  Created by Joachim Kret on 22.11.2014.
//  Copyright (c) 2014 Joachim Kret. All rights reserved.
//

#import "MLTableViewController.h"

#pragma mark - MLTableViewController

@interface MLTableViewController () {
    BOOL _tableViewConstraintsNeedsUpdate;
    BOOL _needsReload;
}

@end

#pragma mark -

@implementation MLTableViewController

@dynamic showsBackgroundView;

+ (UITableViewStyle)defaultTableViewStyle {
    return UITableViewStylePlain;
}

+ (UIEdgeInsets)defaultTableViewInset {
    return UIEdgeInsetsZero;
}

#pragma mark Init / Dealloc

- (instancetype)initWithStyle:(UITableViewStyle)style {
    if (self = [self initWithNibName:nil bundle:nil]) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:style];
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    
    return self;
}

- (void)finishInitialize {
    [super finishInitialize];
    
    _needsReload = NO;
    _reloadOnCurrentLocaleChange = NO;
    _reloadOnAppearsFirstTime = YES;
    _clearsSelectionOnViewWillAppear = YES;
    _clearsSelectionOnReloadData = NO;
    _tableViewConstraintsNeedsUpdate = NO;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark View

- (void)loadView {
    [super loadView];
    
    if (!self.tableView) { // For programmatically init
        UITableViewStyle style = [[self class] defaultTableViewStyle];
        self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:style];
    }
    else if (!self.tableView.superview) { // For programmatically init from initWithStyle:
        _tableViewConstraintsNeedsUpdate = YES;
        self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addSubview:self.tableView];
        [self.view setNeedsUpdateConstraints];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.reloadOnAppearsFirstTime) {
        [self reloadData];
    }
    else {
        [self reloadIfNeeded];
    }
    
    if (self.clearsSelectionOnViewWillAppear) {
        for (NSIndexPath * indexPath in [[self.tableView indexPathsForSelectedRows] copy]) {
            [self.tableView deselectRowAtIndexPath:indexPath animated:animated];
        }
    }
}

#pragma mark Constraints

- (void)updateViewConstraints {
    [super updateViewConstraints];
    
    if (_tableViewConstraintsNeedsUpdate) {
        _tableViewConstraintsNeedsUpdate = NO;
        [self updateTableViewConstraints];
    }
}

- (void)updateTableViewConstraints {
    UIEdgeInsets inset = [[self class] defaultTableViewInset];
    NSDictionary * sizes = @{@"top"         : @(inset.top),
                             @"bottom"      : @(inset.bottom),
                             @"left"        : @(inset.left),
                             @"right"       : @(inset.right)};
    NSDictionary * views = @{@"topGuide"    : self.topLayoutGuide,
                             @"bottomGuide" : self.bottomLayoutGuide,
                             @"tableView"   : self.tableView};
    
    if (self.automaticallyAdjustsScrollViewInsets) {
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(top)-[tableView]-(bottom)-|" options:kNilOptions metrics:sizes views:views]];
        
        UIEdgeInsets scrollInsets = UIEdgeInsetsMake(self.topLayoutGuide.length, 0.0f, self.bottomLayoutGuide.length, 0.0f);
        self.tableView.contentInset = self.tableView.scrollIndicatorInsets = scrollInsets;
    }
    else {
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[topGuide]-(top)-[tableView]-(bottom)-[bottomGuide]|" options:kNilOptions metrics:sizes views:views]];
        
        UIEdgeInsets scrollInsets = UIEdgeInsetsZero;
        self.tableView.contentInset = self.tableView.scrollIndicatorInsets = scrollInsets;
    }
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(left)-[tableView]-(right)-|" options:kNilOptions metrics:sizes views:views]];
}

#pragma mark Editing

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    [self.tableView setEditing:editing animated:animated];
}

#pragma mark Accessors

- (void)setTableView:(UITableView *)tableView {
    if (tableView != _tableView) {
        if (_tableView) {
            [_tableView removeFromSuperview];
            _tableView.delegate = nil;
            _tableView.dataSource = nil;
        }
        
        _tableView = tableView;
        
        if (tableView) {
            if (!tableView.delegate) {
                tableView.delegate = self;
            }
            
            if (!tableView.dataSource) {
                tableView.dataSource = self;
            }
            
            if (!tableView.superview && self.isViewLoaded) {
                _tableViewConstraintsNeedsUpdate = YES;
                tableView.translatesAutoresizingMaskIntoConstraints = NO;
                [self.view addSubview:tableView];
                [self.view setNeedsUpdateConstraints];
            }
        }
    }
}

- (void)setReloadOnCurrentLocaleChange:(BOOL)reloadOnCurrentLocaleChange {
    if (reloadOnCurrentLocaleChange != _reloadOnCurrentLocaleChange) {
        if (_reloadOnCurrentLocaleChange) {
            [[NSNotificationCenter defaultCenter] removeObserver:self
                                                            name:NSCurrentLocaleDidChangeNotification
                                                          object:nil];
        }
        
        _reloadOnCurrentLocaleChange = reloadOnCurrentLocaleChange;
        
        if (reloadOnCurrentLocaleChange) {
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(currentLocaleDidChangeNotification:)
                                                         name:NSCurrentLocaleDidChangeNotification
                                                       object:nil];
        }
    }
}

- (void)setShowsBackgroundView:(BOOL)showsBackgroundView {
    if (showsBackgroundView && !self.isViewLoaded) {
        [self view];
    }
    
    if (showsBackgroundView != self.showsBackgroundView) {
        self.tableView.backgroundView = (showsBackgroundView) ? [self backgroundViewForTableView:self.tableView] : nil;
    }
}

- (BOOL)showsBackgroundView {
    return (nil != self.tableView.backgroundView);
}

- (UIView *)backgroundViewForTableView:(UITableView *)tableView {
    return nil;
}

#pragma mark Reload Data

- (void)setNeedsReload {
    _needsReload = YES;
}

- (BOOL)needsReload {
    return _needsReload;
}

- (void)reloadIfNeeded {
    if (self.needsReload) {
        [self reloadData];
    }
}

- (void)reloadIfVisible {
    if (self.isViewVisible) {
        [self reloadData];
    }
    else {
        [self setNeedsReload];
    }
}

- (void)reloadData {
    NSAssert2([NSThread isMainThread], @"%@: %@ must be called on main thread!", [self class], NSStringFromSelector(_cmd));
    _needsReload = NO;
    
    if (self.isViewVisible) {
        self.reloadOnAppearsFirstTime = NO;
    }
    
    if (self.clearsSelectionOnReloadData) {
        [self.tableView reloadData];
    }
    else {
        NSArray * selectedItems = [[self.tableView indexPathsForSelectedRows] copy];
        
        [self.tableView reloadData];
        
        for (NSIndexPath * indexPath in selectedItems) {
            [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        }
    }
}

#pragma mark Notifications

- (void)currentLocaleDidChangeNotification:(NSNotification *)aNotification {
    if (self.isViewVisible) {
        [self reloadData];
    }
    else {
        [self setNeedsReload];
    }
}

#pragma mark UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

@end
