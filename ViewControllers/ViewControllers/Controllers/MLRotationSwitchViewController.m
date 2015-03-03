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

        NSMutableArray * arrayOfConstraints = [[NSMutableArray alloc] init];
        for (NSLayoutConstraint * constraint in self.view.constraints) {
            if ([constraint.firstItem isEqual:self.containerView] ||
                [constraint.secondItem isEqual:self.containerView]) {
                [arrayOfConstraints addObject:constraint];
            }
        }
        
        [self.view removeConstraints:arrayOfConstraints];
        [arrayOfConstraints removeAllObjects];
        arrayOfConstraints = nil;
        
        
        NSDictionary * views = @{@"container"   : self.containerView,
                                 @"segmented"   : self.segmentedControl};
        
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[container]|" options:0 metrics:nil views:views]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.containerView
                                                              attribute:NSLayoutAttributeTop
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.view
                                                              attribute:NSLayoutAttributeTop
                                                             multiplier:1.0f
                                                               constant:0.0f]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.segmentedControl
                                                              attribute:NSLayoutAttributeTop
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.containerView
                                                              attribute:NSLayoutAttributeBottom
                                                             multiplier:1.0f
                                                               constant:10.0f]];
        
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(10)-[segmented]-(10)-|" options:0 metrics:nil views:views]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.view
                                                              attribute:NSLayoutAttributeBottom
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.segmentedControl
                                                              attribute:NSLayoutAttributeBottom
                                                             multiplier:1.0f
                                                               constant:10.0f]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.segmentedControl
                                                              attribute:NSLayoutAttributeHeight
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:nil
                                                              attribute:NSLayoutAttributeNotAnAttribute
                                                             multiplier:1.0f
                                                               constant:30.0f]];
    }
}

#pragma mark Accessors

- (void)setAutorotationMode:(MLAutorotationMode)autorotationMode {
    [super setAutorotationMode:autorotationMode];
    
    for (MLRotationViewController * viewController in self.viewControllers) {
        viewController.mode = autorotationMode;
        [viewController reloadIfVisible];
    }
}

#pragma mark Actions

- (IBAction)itemDidChange:(id)sender {
    self.selectedIndex = self.segmentedControl.selectedSegmentIndex;
}

@end
