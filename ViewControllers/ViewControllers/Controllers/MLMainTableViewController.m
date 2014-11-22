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

#define INDEX(section, row)     [NSString stringWithFormat:@"%ld=%ld", section, row]

typedef NS_ENUM(NSUInteger, MLSections) {
    MLSectionBaseControllers,
    MLSectionCoreDataControllers,
    MLSectionContainerControllers,
    MLSectionCount
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

typedef NS_ENUM(NSUInteger, MLRowContainerControllers) {
    MLRowContainerNavigationController,
    MLRowContainerTabBarController,
    MLRowContainerPageViewController,
    MLRowContainerSwitchViewController,
    MLRowContainerCount
};

//!!!: Add iPad containers!

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

#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSDictionary * mapping = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mapping = @{
                    //MLSectionBaseControllers
                    INDEX(MLSectionBaseControllers, MLRowBaseViewController)                            : @"MLCustomViewController",
                    INDEX(MLSectionBaseControllers, MLRowBaseTableViewController)                       : @"MLCustomTableViewController",
                    INDEX(MLSectionBaseControllers, MLRowBaseCollectionViewController)                  : @"MLLayoutViewController",
                    
                    //MLSectionCoreDataControllers
                    INDEX(MLSectionCoreDataControllers, MLRowCoreDataFetchedViewController)             : [NSNull null],
                    INDEX(MLSectionCoreDataControllers, MLRowCoreDataFetchedTableViewController)        : [NSNull null],
                    INDEX(MLSectionCoreDataControllers, MLRowCoreDataFetchedCollectionViewController)   : [NSNull null],
                    
                    //MLSectionContainerControllers
                    INDEX(MLSectionContainerControllers, MLRowContainerNavigationController)            : [NSNull null],
                    INDEX(MLSectionContainerControllers, MLRowContainerTabBarController)                : [NSNull null],
                    INDEX(MLSectionContainerControllers, MLRowContainerPageViewController)              : [NSNull null],
                    INDEX(MLSectionContainerControllers, MLRowContainerSwitchViewController)            : [NSNull null],
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
        
        if (configuration && [viewController conformsToProtocol:@protocol(MLCustomConfiguration)]) {
            id <MLCustomConfiguration> controller = (id <MLCustomConfiguration>)viewController;

            if (!viewController.isViewLoaded && [controller respondsToSelector:@selector(finishInitializeWithConfiguration:)]) {
                [controller finishInitializeWithConfiguration:configuration];
            }
            
            if (!viewController.isViewLoaded) {
                [viewController view];
                
                if ([controller respondsToSelector:@selector(finishDidLoadWithConfiguration:)]) {
                    [controller finishDidLoadWithConfiguration:configuration];
                }
            }
        }
        
        [self.navigationController pushViewController:viewController animated:YES];
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
                    //MLSectionBaseControllers
                    INDEX(MLSectionBaseControllers, MLRowBaseViewController)                            : @"View",
                    INDEX(MLSectionBaseControllers, MLRowBaseTableViewController)                       : @"TableView",
                    INDEX(MLSectionBaseControllers, MLRowBaseCollectionViewController)                  : @"CollectionView",
                    
                    //MLSectionCoreDataControllers
                    INDEX(MLSectionCoreDataControllers, MLRowCoreDataFetchedViewController)             : @"Fetched View",
                    INDEX(MLSectionCoreDataControllers, MLRowCoreDataFetchedTableViewController)        : @"Fetched TableView",
                    INDEX(MLSectionCoreDataControllers, MLRowCoreDataFetchedCollectionViewController)   : @"Fetched CollectionView",
                    
                    //MLSectionContainerControllers
                    INDEX(MLSectionContainerControllers, MLRowContainerNavigationController)            : @"Navigation",
                    INDEX(MLSectionContainerControllers, MLRowContainerTabBarController)                : @"TabBar",
                    INDEX(MLSectionContainerControllers, MLRowContainerPageViewController)              : @"Page",
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
                    @(MLSectionBaseControllers)         : @(MLRowBaseCount),
                    @(MLSectionCoreDataControllers)     : @(MLRowCoreDataCount),
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
                    @(MLSectionBaseControllers)         : @"Base Controllers",
                    @(MLSectionCoreDataControllers)     : @"Core Data Controllers",
                    @(MLSectionContainerControllers)    : @"Container Controllers"
                    };
    });
    
    return [mapping objectForKey:@(section)];
}

@end
