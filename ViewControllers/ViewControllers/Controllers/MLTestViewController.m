//
//  MLTestViewController.m
//  ViewControllers
//
//  Created by Joachim Kret on 16.04.2015.
//  Copyright (c) 2015 Joachim Kret. All rights reserved.
//

#import "MLTestViewController.h"

#pragma mark - MLTestViewController

@interface MLTestViewController ()

@end

#pragma mark -

@implementation MLTestViewController

#pragma mark View

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"-> %@", NSStringFromSelector(_cmd));
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSLog(@"-> %@", NSStringFromSelector(_cmd));
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    NSLog(@"-> %@", NSStringFromSelector(_cmd));
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    NSLog(@"-> %@", NSStringFromSelector(_cmd));
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    NSLog(@"-> %@", NSStringFromSelector(_cmd));
}

@end
