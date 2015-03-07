//
//  MLLayoutViewController.m
//  ViewControllers
//
//  Created by Joachim Kret on 22.11.2014.
//  Copyright (c) 2014 Joachim Kret. All rights reserved.
//

#import "MLLayoutViewController.h"

#import "MLTableViewCell.h"
#import "MLCustomCollectionViewController.h"

typedef NS_ENUM(NSUInteger, MLLayoutTypes) {
    MLLayoutTypeFlow,
    MLLayoutTypeSticky,
    MLLayoutTypeUniform,
    MLLayoutTypeCount
};

#pragma mark - MLLayoutViewController

@interface MLLayoutViewController ()

@property (nonatomic, readwrite, assign) BOOL useCoreData;

@end

#pragma mark -

@implementation MLLayoutViewController

#pragma mark Init

- (void)finishInitialize {
    [super finishInitialize];
    
    self.title = @"Layouts";
}

#pragma mark MLCustomConfiguration

- (void)finishInitializeWithConfiguration:(NSDictionary *)dictionary {
    self.useCoreData = [dictionary[@"useCoreData"] boolValue];
}

#pragma mark View

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [MLTableViewCell registerCellWithTableView:self.tableView];
}

#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    static NSDictionary * layouts = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        layouts = @{
                    @(MLLayoutTypeFlow)     : @"UICollectionViewFlowLayout",
                    @(MLLayoutTypeSticky)   : @"MLCollectionViewStickyLayout",
                    @(MLLayoutTypeUniform)  : @"MLUniformFlowLayout",
                    };
    });
    
    id layout = [layouts objectForKey:@(indexPath.row)];
    UICollectionViewLayout * collectionViewLayout = nil;
    
    if (layout && [layout isKindOfClass:[NSString class]]) {
        Class classObj = NSClassFromString((NSString *)layout);
        NSAssert([classObj isSubclassOfClass:[UICollectionViewLayout class]], @"Class '%@' in not subclass of UICollectionViewLayout.", layout);
        collectionViewLayout = [[classObj alloc] init];
    }
    
    UIViewController * viewController = [[MLCustomCollectionViewController alloc] initWithCollectionViewLayout:collectionViewLayout];
    [self.navigationController pushViewController:viewController animated:YES];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell * cell = [MLTableViewCell cellForTableView:tableView indexPath:indexPath];
    
    static NSDictionary * names = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        names = @{
                  @(MLLayoutTypeFlow)       : @"Flow Layout",
                  @(MLLayoutTypeSticky)     : @"Sticky Layout",
                  @(MLLayoutTypeUniform)    : @"Uniform Layout",
                  };
    });
    
    cell.textLabel.text = names[@(indexPath.row)];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return MLLayoutTypeCount;
}

@end
