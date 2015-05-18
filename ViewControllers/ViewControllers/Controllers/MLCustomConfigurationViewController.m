//
//  MLCustomConfigurationViewController.m
//  ViewControllers
//
//  Created by Joachim Kret on 18.05.2015.
//  Copyright (c) 2015 Joachim Kret. All rights reserved.
//

#import "MLCustomConfigurationViewController.h"
#import "MLContainerViewController.h"
#import "MLTabBarController.h"
#import "MLTableViewCell.h"

typedef NS_ENUM(NSUInteger, MLOptions) {
    MLOptionAdjustScrollInsets,
    MLOptionWrapContainer,
    MLOptionWrapTabBar,
    MLOptionLoadFromNib,
    MLOptionCount
};

#pragma mark - MLCustomConfigurationViewController

@interface MLCustomConfigurationViewController ()

@property (nonatomic, readwrite, strong) Class viewControllerClass;
@property (nonatomic, readwrite, assign) BOOL adjustScrollInsets;
@property (nonatomic, readwrite, assign) BOOL wrapContainer;
@property (nonatomic, readwrite, assign) BOOL wrapTabBar;
@property (nonatomic, readwrite, assign) BOOL loadFromNib;

//edgesForExtendedLayout;
//automaticallyAdjustsScrollViewInsets
//extendedLayoutIncludesOpaqueBars

@end

#pragma mark -

@implementation MLCustomConfigurationViewController

+ (NSDictionary *)nibNamesMapping {
    return @{@"MLCustomViewController"      : @"CustomViewController",
             @"MLCustomTableViewController" : @"CustomTableViewController"};
}

#pragma mark View

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.adjustScrollInsets = YES;
    self.clearsSelectionOnReloadData = YES;
    [MLTableViewCell registerCellWithTableView:self.tableView];
    
    UIBarButtonItem * rightItem = [[UIBarButtonItem alloc] initWithTitle:@"Show" style:UIBarButtonItemStylePlain target:self action:@selector(show:)];
    self.navigationItem.rightBarButtonItem = rightItem;
}

#pragma mark Configuration

- (void)configureWithObject:(id)anObject context:(id)context {
    if (![self isViewLoaded]) {
        [self view];
    }
    
    self.viewControllerClass = NSClassFromString(anObject[@"viewControllerClass"]);
}

#pragma mark Actions

- (IBAction)show:(id)sender {
    NSParameterAssert(self.viewControllerClass && [self.viewControllerClass isSubclassOfClass:[UIViewController class]]);

    NSString * classString = NSStringFromClass(self.viewControllerClass);
    NSString * nibName = (self.loadFromNib) ? [[[self class] nibNamesMapping] objectForKey:classString] : nil;
    NSBundle * bundle = (nibName) ? [NSBundle bundleForClass:[self class]] : nil;
    NSLog(@"Create view controller: %@ from nib name: %@", classString, nibName);
    
    UIViewController * viewController = [[self.viewControllerClass alloc] initWithNibName:nibName bundle:bundle];
    UIViewController * pushViewController = viewController;
    NSAssert2(!nibName || [nibName isEqualToString:viewController.nibName], @"View controller nib name: %@ is not equal with: %@", viewController.nibName, nibName);
    
    if (![pushViewController isViewLoaded]) {
        [pushViewController view];
    }
    
    pushViewController.automaticallyAdjustsScrollViewInsets = self.adjustScrollInsets;
    
    if (self.wrapContainer) {
        MLContainerViewController * containerController = [[MLContainerViewController alloc] init];
        containerController.view.backgroundColor = [UIColor clearColor];
        containerController.viewControllers = @[pushViewController];
        pushViewController = containerController;
    }
    
    if (self.wrapTabBar) {
        MLTabBarController * tabBarController = [[MLTabBarController alloc] init];
        tabBarController.view.backgroundColor = [UIColor clearColor];
        tabBarController.viewControllers = @[pushViewController];
        pushViewController = tabBarController;
    }
    
    [self.navigationController pushViewController:pushViewController animated:YES];
}

#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch ((MLOptions)indexPath.row) {
        case MLOptionAdjustScrollInsets: {
            self.adjustScrollInsets = !self.adjustScrollInsets;
        } break;
        case MLOptionWrapContainer: {
            self.wrapContainer = !self.wrapContainer;
        } break;
        case MLOptionWrapTabBar: {
            self.wrapTabBar = !self.wrapTabBar;
        } break;
        case MLOptionLoadFromNib: {
            self.loadFromNib = !self.loadFromNib;
        } break;
        default: break;
    }
    
    [self reloadData];
}

#pragma mark UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MLTableViewCell * cell = [MLTableViewCell cellForTableView:tableView indexPath:indexPath];
    
    switch ((MLOptions)indexPath.row) {
        case MLOptionAdjustScrollInsets: {
            cell.textLabel.text = @"Adjust scroll insets";
            cell.accessoryType = (self.adjustScrollInsets) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
        } break;
        case MLOptionWrapContainer: {
            cell.textLabel.text = @"Wrap into Container";
            cell.accessoryType = (self.wrapContainer) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
        } break;
        case MLOptionWrapTabBar: {
            cell.textLabel.text = @"Wrap into TabBar";
            cell.accessoryType = (self.wrapTabBar) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
        } break;
        case MLOptionLoadFromNib: {
            cell.textLabel.text = @"Load from Nib";
            cell.accessoryType = (self.loadFromNib) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
        } break;
        default: break;
    }
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return MLOptionCount;
}

@end
