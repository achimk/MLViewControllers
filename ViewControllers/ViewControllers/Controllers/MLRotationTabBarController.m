//
//  MLRotationTabBarController.m
//  ViewControllers
//
//  Created by Joachim Kret on 27.02.2015.
//  Copyright (c) 2015 Joachim Kret. All rights reserved.
//

#import "MLRotationTabBarController.h"
#import "MLRotationViewController.h"

#pragma mark - MLRotationViewController

@interface MLRotationViewController ()

@property (nonatomic, readwrite, assign) MLAutorotationMode mode;

@end

#pragma mark - MLRotationTabBarController

@interface MLRotationTabBarController ()

@end

#pragma mark -

@implementation MLRotationTabBarController

#pragma mark Init

- (void)finishInitialize {
    [super finishInitialize];
    
    self.viewControllers = @[[[MLRotationViewController alloc] init],
                             [[MLRotationViewController alloc] init],
                             [[MLRotationViewController alloc] init],
                             [[MLRotationViewController alloc] init]];

    for (NSInteger i = 0; i < self.viewControllers.count; i++) {
        UIViewController * viewController = self.viewControllers[i];
        viewController.title = [NSString stringWithFormat:@"Rotation %ld", i];
    }
}

#pragma mark View

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.parentViewController && [self.parentViewController conformsToProtocol:@protocol(MLAutorotation)]) {
        [(id <MLAutorotation>)self.parentViewController setAutorotationMode:MLAutorotationModeContainerAndTopChildren];
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

@end
