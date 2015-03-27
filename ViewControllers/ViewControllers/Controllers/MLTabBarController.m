//
//  MLTabBarController.m
//  ViewControllers
//
//  Created by Joachim Kret on 22.11.2014.
//  Copyright (c) 2014 Joachim Kret. All rights reserved.
//

#import "MLTabBarController.h"

#pragma mark - MLTabBarController

@interface MLTabBarController ()

@end

#pragma mark -

@implementation MLTabBarController

#pragma mark Init

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self finishInitialize];
    }
    
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        [self finishInitialize];
    }
    
    return self;
}

- (void)finishInitialize {
    _autorotationMode = MLAutorotationModeContainer;
    _appearsFirstTime = YES;
    _viewVisible = NO;
}

#pragma mark View

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    _viewVisible = YES;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    _appearsFirstTime = NO;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    _viewVisible = NO;
}

#pragma mark Rotations

- (BOOL)shouldAutorotate {
    switch (self.autorotationMode) {
        case MLAutorotationModeContainer: {
            return [super shouldAutorotate];
        } break;
            
        case MLAutorotationModeContainerAndTopChildren: {
            UIViewController * topViewController = self.selectedViewController;
            if (![topViewController shouldAutorotate]) {
                return NO;
            }
        } break;
            
        case MLAutorotationModeContainerAndAllChildren: {
            for (UIViewController * viewController in self.viewControllers) {
                if (![viewController shouldAutorotate]) {
                    return NO;
                }
            }
        } break;
    }
    
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
    NSUInteger containerSupportedInterfaceOrientations = UIInterfaceOrientationMaskAll;
    
    switch (self.autorotationMode) {
        case MLAutorotationModeContainer: {
            containerSupportedInterfaceOrientations = [super supportedInterfaceOrientations];
        } break;
            
        case MLAutorotationModeContainerAndTopChildren: {
            UIViewController * topViewController = self.selectedViewController;
            containerSupportedInterfaceOrientations &= [topViewController supportedInterfaceOrientations];
        } break;
            
        case MLAutorotationModeContainerAndAllChildren: {
            for (UIViewController * viewController in self.viewControllers) {
                containerSupportedInterfaceOrientations &= [viewController supportedInterfaceOrientations];
            }
        } break;
    }
    
    return containerSupportedInterfaceOrientations;
}

@end
