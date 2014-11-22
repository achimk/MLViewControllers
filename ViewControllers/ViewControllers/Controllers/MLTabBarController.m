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

@synthesize appearsFirstTime = _appearsFirstTime;
@synthesize viewVisible = _viewVisible;

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
    if (![super shouldAutorotate]) {
        return NO;
    }
    
    switch (self.autorotationMode) {
        case MLAutorotationModeContainerAndTopChildren:
        case MLAutorotationModeContainerAndAllChildren: {
            for (UIViewController * viewController in self.viewControllers) {
                if (! [viewController shouldAutorotate]) {
                    return NO;
                }
            }
        } break;
            
        case MLAutorotationModeContainerAndNoChildren:
        case MLAutorotationModeContainer:
        default: {
        } break;
    }
    
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
    NSUInteger containerSupportedInterfaceOrientations = [super supportedInterfaceOrientations];
    
    switch (self.autorotationMode) {
        case MLAutorotationModeContainerAndAllChildren:
        case MLAutorotationModeContainerAndTopChildren: {
            for (UIViewController * viewController in self.viewControllers) {
                containerSupportedInterfaceOrientations &= [viewController supportedInterfaceOrientations];
            }
        } break;
            
        case MLAutorotationModeContainerAndNoChildren:
        case MLAutorotationModeContainer:
        default: {
        } break;
    }
    
    return containerSupportedInterfaceOrientations;
}

@end
