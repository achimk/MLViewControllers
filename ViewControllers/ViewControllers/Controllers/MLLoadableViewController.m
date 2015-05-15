//
//  MLLoadableViewController.m
//  ViewControllers
//
//  Created by Joachim Kret on 24.03.2015.
//  Copyright (c) 2015 Joachim Kret. All rights reserved.
//

#import "MLLoadableViewController.h"
#import "MLLoadableContent.h"
#import "RZCollectionList.h"
#import "RZBaseCollectionList+MLResultsController.h"
#import "RZArrayCollectionList+MLResultsController.h"
#import "MLLoadableTableViewController.h"
#import "MLLoadableCollectionViewController.h"
#import "MLLoadableSettingsViewController.h"

#define LOAD_TIME_INTERVAL      2.0f
#define NUMBER_OF_LOAD_ITEMS    ((IS_IPHONE) ? 6 : 18)

#pragma mark - MLLoadableViewController

@interface MLLoadableViewController () <
    MLLoadableContentDelegate,
    MLLoadableContentDataSource
>

@property (nonatomic, readwrite, strong) MLLoadableContent * loadableContent;
@property (nonatomic, readwrite, strong) RZArrayCollectionList * resultsController;
@property (nonatomic, readwrite, strong) UISegmentedControl * segmentedControl;

@property (nonatomic, readwrite, strong) MLLoadableTableViewController * loadableTableViewController;
@property (nonatomic, readwrite, strong) MLLoadableCollectionViewController * loadableCollectionViewController;
@property (nonatomic, readwrite, strong) MLLoadableSettingsViewController * loadableSettingsViewController;

@end

#pragma mark -

@implementation MLLoadableViewController

#pragma mark Init

- (void)finishInitialize {
    [super finishInitialize];
    
    MLLoadableContentType type = MLLoadableContentTypePaging;
    _loadableContent = [[MLLoadableContent alloc] initWithType:type];
    _loadableContent.delegate = self;
    _loadableContent.dataSource = self;
    
    _resultsController = [[RZArrayCollectionList alloc] initWithArray:@[] sectionNameKeyPath:nil];
    
    MLLoadableSettingsViewController * loadableSettingsViewController = [[MLLoadableSettingsViewController alloc] init];
    loadableSettingsViewController.title = @"Settings";
    self.loadableSettingsViewController = loadableSettingsViewController;
    
    MLLoadableTableViewController * loadableTableViewController = [[MLLoadableTableViewController alloc] init];
    loadableTableViewController.loadableContent = self.loadableContent;
    loadableTableViewController.resultsController = self.resultsController;
    loadableTableViewController.title = @"Table";
    self.loadableTableViewController = loadableTableViewController;
    
    MLLoadableCollectionViewController * loadableCollectionViewController = [[MLLoadableCollectionViewController alloc] init];
    loadableCollectionViewController.loadableContent = self.loadableContent;
    loadableCollectionViewController.resultsController = self.resultsController;
    loadableCollectionViewController.title = @"Collection";
    self.loadableCollectionViewController = loadableCollectionViewController;
    
    self.viewControllers = @[loadableSettingsViewController,
                             loadableTableViewController,
                             loadableCollectionViewController];
}

#pragma mark View

- (void)loadView {
    [super loadView];
    
    if (!_segmentedControl) {
        UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] init];
        segmentedControl.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addSubview:segmentedControl];
        self.segmentedControl = segmentedControl;
        [self.view setNeedsUpdateConstraints];
        
        for (NSInteger i = 0; i < self.viewControllers.count; i++) {
            NSString * title = [[self.viewControllers objectAtIndex:i] title];
            [segmentedControl insertSegmentWithTitle:title atIndex:i animated:NO];
        }
        
        [segmentedControl addTarget:self action:@selector(itemDidChange:) forControlEvents:UIControlEventValueChanged];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.segmentedControl.selectedSegmentIndex = 0;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                                                           target:self
                                                                                           action:@selector(refreshAction:)];
}

#pragma mark Constraints

- (void)updateContainerViewConstraints {
    NSDictionary * views = @{@"topGuide"            : self.topLayoutGuide,
                             @"segmentedControl"    : self.segmentedControl,
                             @"containerView"       : self.containerView};
    NSDictionary * sizes = @{@"margin"              : @(10.0f)};
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[topGuide]-(margin)-[segmentedControl]-(margin)-[containerView]|"
                                                                      options:0
                                                                      metrics:sizes
                                                                        views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(margin)-[segmentedControl]-(margin)-|"
                                                                      options:0
                                                                      metrics:sizes
                                                                        views:views]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.segmentedControl
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:nil
                                                          attribute:NSLayoutAttributeNotAnAttribute
                                                         multiplier:1.0f
                                                           constant:28.0f]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[containerView]|" options:kNilOptions metrics:nil views:views]];
}

#pragma mark Actions

- (IBAction)itemDidChange:(id)sender {
    self.selectedIndex = self.segmentedControl.selectedSegmentIndex;
}

- (IBAction)refreshAction:(id)sender {
    [self.loadableContent refreshContent];
}

#pragma mark MLLoadableContentDelegate

- (void)loadableContentDidChangeState:(MLLoadableContent *)loadableContent {
    [self.loadableTableViewController.dataSource updateLoadingCell];
    [self.loadableCollectionViewController.dataSource updateLoadingCell];
}

#pragma mark MLLoadableContentDataSource

- (void)loadableContent:(MLLoadableContent *)loadableContent loadDataWithLoadToken:(MLLoadToken *)loadToken {
    BOOL refreshItems = ([loadableContent.currentState isEqualToString:MLContentStateRefreshing]);
    __weak typeof(self)weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(LOAD_TIME_INTERVAL * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (MLLoadTokenStateIgnore == loadToken.state) {
            return;
        }

        RZArrayCollectionList * collectionList = [weakSelf resultsController];
        [collectionList beginUpdates];
        
        if (refreshItems) {
            NSArray * allObjects = [collectionList.allObjects copy];
            for (id object in allObjects) {
                [collectionList removeObject:object];
            }
        }
        
        for (NSUInteger i = 0; i < NUMBER_OF_LOAD_ITEMS; i++) {
            [collectionList addObject:[NSDate date] toSection:0];
        }
        
        [collectionList endUpdates];
        
        [loadToken success:@(NUMBER_OF_LOAD_ITEMS)];
    });
}

@end
