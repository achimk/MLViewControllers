//
//  MLRotationContainerViewController.m
//  ViewControllers
//
//  Created by Joachim Kret on 09.05.2015.
//  Copyright (c) 2015 Joachim Kret. All rights reserved.
//

#import "MLRotationContainerViewController.h"
#import "MLRotationViewController.h"
#import "MLTableViewController.h"
#import "MLTableViewCell.h"

typedef NS_ENUM(NSUInteger, MLConfigurationContainer) {
    MLConfigurationContainerInit,
    MLConfigurationContainerStoryboard,
    MLConfigurationContainerCount
};

#pragma mark - MLRotationViewController

@interface MLRotationViewController ()

@property (nonatomic, readwrite, assign) MLAutorotationMode mode;

@end

#pragma mark - MLConfigurationContainerViewController

@interface MLConfigurationContainerViewController : MLTableViewController

@end

#pragma mark -

@implementation MLConfigurationContainerViewController

#pragma mark View

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [MLTableViewCell registerCellWithTableView:self.tableView];
}

#pragma mark Accessors

- (NSString *)title {
    return @"Configuration";
}

#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UIViewController * viewController = nil;
    
    switch (indexPath.row) {
        case MLConfigurationContainerInit: {
            MLRotationContainerViewController * containerViewController = [[MLRotationContainerViewController alloc] init];
            containerViewController.viewControllers = @[[[MLRotationViewController alloc] init],
                                                        [[MLRotationViewController alloc] init],
                                                        [[MLRotationViewController alloc] init],
                                                        [[MLRotationViewController alloc] init]];
            viewController = containerViewController;
        } break;
        case MLConfigurationContainerStoryboard: {
            NSBundle * bundle = [NSBundle bundleForClass:[self class]];
            UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"CustomContainer" bundle:bundle];
            MLRotationContainerViewController * containerViewController = [storyboard instantiateInitialViewController];
            containerViewController.segueIdentifiers = @[@"Container1", @"Container2", @"Container3", @"Container4"];
            viewController = containerViewController;
        } break;
    }
    
    if (viewController) {
        [self.navigationController pushViewController:viewController animated:YES];
    }
}

#pragma mark UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MLTableViewCell * cell = [MLTableViewCell cellForTableView:tableView indexPath:indexPath];
    
    switch (indexPath.row) {
        case MLConfigurationContainerInit: {
            cell.textLabel.text = @"Init";
        } break;
        case MLConfigurationContainerStoryboard: {
            cell.textLabel.text = @"Storyboard";
        } break;
    }
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return MLConfigurationContainerCount;
}

@end

#pragma mark - MLRotationContainerViewController

@interface MLRotationContainerViewController () {
    BOOL _segmentedControlConstraintsNeedsUpdate;
}

@property (nonatomic, readwrite, strong) IBOutlet UISegmentedControl * segmentedControl;

- (IBAction)changeContent:(id)sender;

@end

#pragma mark -

@implementation MLRotationContainerViewController

+ (UIEdgeInsets)defaultContainerViewInset {
    return UIEdgeInsetsMake(48.0f, 0.0f, 0.0f, 0.0f);
}

#pragma mark View

- (void)loadView {
    [super loadView];
    
    if (!_segmentedControl) {
        _segmentedControlConstraintsNeedsUpdate = YES;
        UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] init];
        segmentedControl.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addSubview:segmentedControl];
        self.segmentedControl = segmentedControl;
        [self.view setNeedsUpdateConstraints];
        
        for (NSInteger i = 0; i < self.viewControllers.count; i++) {
            NSString * title = [NSString stringWithFormat:@"Item %@", @(i + 1)];
            [segmentedControl insertSegmentWithTitle:title atIndex:i animated:NO];
        }
        
        [segmentedControl addTarget:self action:@selector(changeContent:) forControlEvents:UIControlEventValueChanged];
    }
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.containerView.backgroundColor = [UIColor lightGrayColor];
    self.segmentedControl.selectedSegmentIndex = 0;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.parentViewController && [self.parentViewController conformsToProtocol:@protocol(MLAutorotation)]) {
        [(id <MLAutorotation>)self.parentViewController setAutorotationMode:MLAutorotationModeContainerAndTopChildren];
    }
}

#pragma mark Constraints

- (void)updateViewConstraints {
    [super updateViewConstraints];
    
    if (_segmentedControlConstraintsNeedsUpdate) {
        _segmentedControlConstraintsNeedsUpdate = NO;
        
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
    }
}

#pragma mark Accessors

- (void)setAutorotationMode:(MLAutorotationMode)autorotationMode {
    [super setAutorotationMode:autorotationMode];
    
    for (MLRotationViewController * viewController in self.viewControllers) {
        viewController.mode = autorotationMode;
        [viewController reloadData];
    }
}

#pragma mark Actions

- (IBAction)changeContent:(id)sender {
    self.selectedIndex = self.segmentedControl.selectedSegmentIndex;
}

@end
