//
//  MLNavigationController.m
//  ViewControllers
//
//  Created by Joachim Kret on 22.11.2014.
//  Copyright (c) 2014 Joachim Kret. All rights reserved.
//

#import "MLNavigationController.h"

#pragma mark - MLNavigationController

@interface MLNavigationController ()

@end

#pragma mark -

@implementation MLNavigationController

#pragma mark Init

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self finishInitialize];
    }
    
    return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
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
            UIViewController * topViewController = self.topViewController;
            if (![topViewController shouldAutorotate]) {
                return NO;
            }
        } break;
            
        case MLAutorotationModeContainerAndAllChildren: {
            for (UIViewController * viewController in [self.viewControllers reverseObjectEnumerator]) {
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
            UIViewController * topViewController = self.topViewController;
            containerSupportedInterfaceOrientations &= [topViewController supportedInterfaceOrientations];
        } break;
            
        case MLAutorotationModeContainerAndAllChildren: {
            for (UIViewController * viewController in [self.viewControllers reverseObjectEnumerator]) {
                containerSupportedInterfaceOrientations &= [viewController supportedInterfaceOrientations];
            }
        } break;
    }
    
    return containerSupportedInterfaceOrientations;
}

@end
