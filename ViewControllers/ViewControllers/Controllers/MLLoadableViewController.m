//
//  MLLoadableViewController.m
//  ViewControllers
//
//  Created by Joachim Kret on 24.03.2015.
//  Copyright (c) 2015 Joachim Kret. All rights reserved.
//

#import "MLLoadableViewController.h"
#import "MLLoadableContentViewModel.h"
#import "MLCollectionListController.h"
#import "RZCollectionList.h"
#import "MLLoadableTableViewController.h"
#import "MLLoadableCollectionViewController.h"
#import "MLLoadableSettingsViewController.h"

#define LOAD_TIME_INTERVAL      2.0f
#define NUMBER_OF_LOAD_ITEMS    5

#pragma mark - MLLoadableViewController

@interface MLLoadableViewController () <MLLoadableContentDelegate>

@property (nonatomic, readwrite, strong) MLLoadableContentViewModel * loadableContentViewModel;
@property (nonatomic, readwrite, strong) MLCollectionListController * collectionListController;

@end

#pragma mark -

@implementation MLLoadableViewController

#pragma mark Init

- (void)finishInitialize {
    [super finishInitialize];
    
    MLLoadableContentType type = MLLoadableContentTypePaging;
    _loadableContentViewModel = [[MLLoadableContentViewModel alloc] initWithType:type];
    _loadableContentViewModel.delegate = self;
    
    RZArrayCollectionList * collectionList = [[RZArrayCollectionList alloc] initWithArray:@[] sectionNameKeyPath:nil];
    _collectionListController = [[MLCollectionListController alloc] initWithCollectionList:collectionList];
    
    MLLoadableTableViewController * loadableTableViewController = [[MLLoadableTableViewController alloc] init];
    loadableTableViewController.loadableContentViewModel = self.loadableContentViewModel;
    loadableTableViewController.resultsController = self.collectionListController;
    loadableTableViewController.title = @"Table";
    
    MLLoadableCollectionViewController * loadableCollectionViewController = [[MLLoadableCollectionViewController alloc] init];
    loadableCollectionViewController.loadableContentViewModel = self.loadableContentViewModel;
    loadableCollectionViewController.resultsController = self.collectionListController;
    loadableCollectionViewController.title = @"Collection";
    
    self.viewControllers = @[loadableTableViewController,
                             loadableCollectionViewController];
}

#pragma mark Configure

- (void)finishInitializeWithConfiguration:(NSDictionary *)dictionary {

}

#pragma mark View

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                                                           target:self
                                                                                           action:@selector(refreshAction:)];
}

#pragma mark Accessors

- (RZArrayCollectionList *)arrayCollectionList {
    return self.collectionListController.collectionList;
}

#pragma mark Actions

- (IBAction)refreshAction:(id)sender {
    [self.loadableContentViewModel refreshContent];
}

#pragma mark MLLoadableContentDelegate

- (void)loadableContent:(MLLoadableContentViewModel *)loadableContent loadDataWithLoadToken:(MLLoadToken *)loadToken {
    BOOL refreshItems = ([loadableContent.currentState isEqualToString:MLContentStateRefreshing]);
    __weak typeof(self)weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(LOAD_TIME_INTERVAL * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (MLLoadTokenStateIgnore == loadToken.state) {
            return;
        }
        
        [loadToken success:@(NUMBER_OF_LOAD_ITEMS)];
        
        RZArrayCollectionList * collectionList = [weakSelf arrayCollectionList];
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

@end
