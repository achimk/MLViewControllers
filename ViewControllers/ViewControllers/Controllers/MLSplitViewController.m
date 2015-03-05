//
//  MLSplitViewController.m
//  ViewControllers
//
//  Created by Joachim Kret on 22.11.2014.
//  Copyright (c) 2014 Joachim Kret. All rights reserved.
//

#import "MLSplitViewController.h"

#pragma mark - MLSplitViewController

@interface MLSplitViewController ()

@end

#pragma mark -

@implementation MLSplitViewController

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
    switch (self.autorotationMode) {
        case MLAutorotationModeContainer: {
            return [super shouldAutorotate];
        } break;
            
        case MLAutorotationModeContainerAndAllChildren:
        case MLAutorotationModeContainerAndTopChildren: {
            for (UIViewController * viewController in self.viewControllers) {
                if (! [viewController shouldAutorotate]) {
                    return NO;
                }
            }
        } break;
            
        case MLAutorotationModeContainerAndNoChildren: break;
    }
    
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
    NSUInteger containerSupportedInterfaceOrientations = UIInterfaceOrientationMaskAll;
    
    switch (self.autorotationMode) {
        case MLAutorotationModeContainer: {
            containerSupportedInterfaceOrientations = [super supportedInterfaceOrientations];
        } break;
            
        case MLAutorotationModeContainerAndAllChildren:
        case MLAutorotationModeContainerAndTopChildren: {
            for (UIViewController * viewController in self.viewControllers) {
                containerSupportedInterfaceOrientations &= [viewController supportedInterfaceOrientations];
            }
        } break;
            
        case MLAutorotationModeContainerAndNoChildren: break;
    }
    
    return containerSupportedInterfaceOrientations;
}

@end
