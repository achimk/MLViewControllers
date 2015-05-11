//
//  MLRotationSwitchViewController.m
//  ViewControllers
//
//  Created by Joachim Kret on 27.02.2015.
//  Copyright (c) 2015 Joachim Kret. All rights reserved.
//

#import "MLRotationSwitchViewController.h"
#import "MLRotationViewController.h"

#pragma mark - MLRotationViewController

@interface MLRotationViewController ()

@property (nonatomic, readwrite, assign) MLAutorotationMode mode;

@end

#pragma mark - MLRotationSwitchViewController

@interface MLRotationSwitchViewController () {
    BOOL _segmentedControlConstraintsNeedsUpdate;
}

@property (nonatomic, readwrite, strong) UISegmentedControl * segmentedControl;

@end

#pragma mark -

@implementation MLRotationSwitchViewController

+ (UIEdgeInsets)defaultContainerViewInset {
    return UIEdgeInsetsMake(48.0f, 0.0f, 0.0f, 0.0f);
}

#pragma mark Init

- (void)finishInitialize {
    [super finishInitialize];
    
    self.viewControllers = @[[[MLRotationViewController alloc] init],
                             [[MLRotationViewController alloc] init],
                             [[MLRotationViewController alloc] init],
                             [[MLRotationViewController alloc] init]];
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
            NSString * title = [NSString stringWithFormat:@"Item %ld", i];
            [segmentedControl insertSegmentWithTitle:title atIndex:i animated:NO];
        }
        
        [segmentedControl addTarget:self action:@selector(itemDidChange:) forControlEvents:UIControlEventValueChanged];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
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

- (IBAction)itemDidChange:(id)sender {
    self.selectedIndex = self.segmentedControl.selectedSegmentIndex;
}

@end
