//
//  MLMainTableViewController.m
//  ViewControllers
//
//  Created by Joachim Kret on 22.11.2014.
//  Copyright (c) 2014 Joachim Kret. All rights reserved.
//

#import "MLMainTableViewController.h"

#import "MLCustomConfiguration.h"
#import "MLTableViewCell.h"
#import "MLAutorotation.h"

#define INDEX(section, row)     [NSString stringWithFormat:@"%ld=%ld", section, row]

typedef NS_ENUM(NSUInteger, MLSections) {
    MLSectionCells,
    MLSectionBaseControllers,
    MLSectionCoreDataControllers,
    MLSectionDataSourceControllers,
    MLSectionContainerControllers,
    MLSectionCount
};

typedef NS_ENUM(NSUInteger, MLRowCells) {
    MLRowCellTableView,
    MLRowCellCollectionView,
    MLRowCellCount
};

typedef NS_ENUM(NSUInteger, MLRowBaseControllers) {
    MLRowBaseViewController,
    MLRowBaseTableViewController,
    MLRowBaseCollectionViewController,
    MLRowBaseCount
};

typedef NS_ENUM(NSUInteger, MLRowCoreDataControllers) {
    MLRowCoreDataFetchedViewController,
    MLRowCoreDataFetchedTableViewController,
    MLRowCoreDataFetchedCollectionViewController,
    MLRowCoreDataCount
};

typedef NS_ENUM(NSUInteger, MLRowDataSourceControllers) {
    MLRowDataSourceArrayTableController,
    MLRowDataSourceArrayCollectionController,
    MLRowDataSourceFetchedTableController,
    MLRowDataSourceFetchedCollectionController,
    MLRowDataSourceCount
};

typedef NS_ENUM(NSUInteger, MLRowContainerControllers) {
    MLRowContainerNavigationController,
    MLRowContainerTabBarController,
    MLRowContainerSwitchViewController,
    MLRowContainerCount
};

#pragma mark - MLMainTableViewController

@interface MLMainTableViewController ()

@end

#pragma mark -

@implementation MLMainTableViewController

#pragma mark Init

- (void)finishInitialize {
    [super finishInitialize];
    
    self.title = @"Main";
}

#pragma mark View

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [MLTableViewCell registerCellWithTableView:self.tableView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.parentViewController && [self.parentViewController conformsToProtocol:@protocol(MLAutorotation)]) {
        [(id <MLAutorotation>)self.parentViewController setAutorotationMode:MLAutorotationModeContainer];
    }
}

#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSDictionary * mapping = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mapping = @{
                    //MLSectionCells
                    INDEX(MLSectionCells, MLRowCellTableView)                                           : @"MLContactsTableViewController",
                    INDEX(MLSectionCells, MLRowCellCollectionView)                                      : @"MLContactsCollectionViewController",
                    
                    //MLSectionBaseControllers
                    INDEX(MLSectionBaseControllers, MLRowBaseViewController)                            : @"MLCustomViewController",
                    INDEX(MLSectionBaseControllers, MLRowBaseTableViewController)                       : @"MLCustomTableViewController",
                    INDEX(MLSectionBaseControllers, MLRowBaseCollectionViewController)                  : @"MLLayoutViewController",
                    
                    //MLSectionCoreDataControllers
                    INDEX(MLSectionCoreDataControllers, MLRowCoreDataFetchedViewController)             : [NSNull null],
                    INDEX(MLSectionCoreDataControllers, MLRowCoreDataFetchedTableViewController)        : [NSNull null],
                    INDEX(MLSectionCoreDataControllers, MLRowCoreDataFetchedCollectionViewController)   : [NSNull null],
                    
                    //MLSectionDataSourceControllers
                    INDEX(MLSectionDataSourceControllers, MLRowDataSourceArrayTableController)          : @"MLArrayDataTableViewController",
                    INDEX(MLSectionDataSourceControllers, MLRowDataSourceArrayCollectionController)     : [NSNull null],
                    INDEX(MLSectionDataSourceControllers, MLRowDataSourceFetchedTableController)        : [NSNull null],
                    INDEX(MLSectionDataSourceControllers, MLRowDataSourceFetchedCollectionController)   : [NSNull null],
                    
                    //MLSectionContainerControllers
                    INDEX(MLSectionContainerControllers, MLRowContainerNavigationController)            : @"MLRotationViewController",
                    INDEX(MLSectionContainerControllers, MLRowContainerTabBarController)                : @"MLRotationTabBarController",
                    INDEX(MLSectionContainerControllers, MLRowContainerSwitchViewController)            : @"MLRotationSwitchViewController"
                    };
    });
    
    static NSDictionary * configurations = nil;
    static dispatch_once_t secondToken;
    dispatch_once(&secondToken, ^{
        configurations = @{
                           INDEX(MLSectionBaseControllers, MLRowBaseCollectionViewController)                : @{@"useCoreData"  : @(NO)},
                           INDEX(MLSectionCoreDataControllers, MLRowCoreDataFetchedCollectionViewController) : @{@"useCoreData"  : @(YES)},
                           };
    });
    
    
    id obj = [mapping objectForKey:INDEX(indexPath.section, indexPath.row)];
    id configuration = [configurations objectForKey:INDEX(indexPath.section, indexPath.row)];
    
    if (![obj isEqual:[NSNull null]] && [obj isKindOfClass:[NSString class]]) {
        Class classObj = NSClassFromString((NSString *)obj);
        NSAssert1([classObj isSubclassOfClass:[UIViewController class]], @"Class '%@' is not subclass of UIViewController.", obj);
        UIViewController * viewController = [[classObj alloc] init];
        [self.navigationController ml_pushViewController:viewController withConfiguration:configuration animated:YES];
    }
    else {
        NSLog(@"-> Unsupported selection for index path: %@", indexPath);
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell * cell = [MLTableViewCell cellForTableView:tableView indexPath:indexPath];
    
    static NSDictionary * mapping = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mapping = @{
                    //MLSectionCells
                    INDEX(MLSectionCells, MLRowCellTableView)                                           : @"UITableViewCell",
                    INDEX(MLSectionCells, MLRowCellCollectionView)                                      : @"UICollectionViewCell",
                    
                    //MLSectionBaseControllers
                    INDEX(MLSectionBaseControllers, MLRowBaseViewController)                            : @"View",
                    INDEX(MLSectionBaseControllers, MLRowBaseTableViewController)                       : @"TableView",
                    INDEX(MLSectionBaseControllers, MLRowBaseCollectionViewController)                  : @"CollectionView",
                    
                    //MLSectionCoreDataControllers
                    INDEX(MLSectionCoreDataControllers, MLRowCoreDataFetchedViewController)             : @"Fetched View",
                    INDEX(MLSectionCoreDataControllers, MLRowCoreDataFetchedTableViewController)        : @"Fetched TableView",
                    INDEX(MLSectionCoreDataControllers, MLRowCoreDataFetchedCollectionViewController)   : @"Fetched CollectionView",
                    
                    //MLSectionDataSourceControllers
                    INDEX(MLSectionDataSourceControllers, MLRowDataSourceArrayTableController)          : @"Array TableView",
                    INDEX(MLSectionDataSourceControllers, MLRowDataSourceArrayCollectionController)     : @"Array CollectionView",
                    INDEX(MLSectionDataSourceControllers, MLRowDataSourceFetchedTableController)        : @"Fetched TableView",
                    INDEX(MLSectionDataSourceControllers, MLRowDataSourceFetchedCollectionController)   : @"Fetched CollectionView",
                    
                    //MLSectionContainerControllers
                    INDEX(MLSectionContainerControllers, MLRowContainerNavigationController)            : @"Navigation",
                    INDEX(MLSectionContainerControllers, MLRowContainerTabBarController)                : @"TabBar",
                    INDEX(MLSectionContainerControllers, MLRowContainerSwitchViewController)            : @"Switch",
                    };
    });
    
    cell.textLabel.text = [mapping objectForKey:INDEX(indexPath.section, indexPath.row)];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return MLSectionCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    static NSDictionary * mapping = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mapping = @{
                    @(MLSectionCells)                   : @(MLRowCellCount),
                    @(MLSectionBaseControllers)         : @(MLRowBaseCount),
                    @(MLSectionCoreDataControllers)     : @(MLRowCoreDataCount),
                    @(MLSectionDataSourceControllers)   : @(MLRowDataSourceCount),
                    @(MLSectionContainerControllers)    : @(MLRowContainerCount)
                    };
    });
    
    return [[mapping objectForKey:@(section)] integerValue];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    static NSDictionary * mapping = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mapping = @{
                    @(MLSectionCells)                   : @"Cells Layout",
                    @(MLSectionBaseControllers)         : @"Base Controllers",
                    @(MLSectionCoreDataControllers)     : @"Core Data Controllers",
                    @(MLSectionDataSourceControllers)   : @"Data Source Controllers",
                    @(MLSectionContainerControllers)    : @"Container Controllers"
                    };
    });
    
    return [mapping objectForKey:@(section)];
}

@end
