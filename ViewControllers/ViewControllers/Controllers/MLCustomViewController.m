//
//  MLCustomViewController.m
//  ViewControllers
//
//  Created by Joachim Kret on 22.11.2014.
//  Copyright (c) 2014 Joachim Kret. All rights reserved.
//

#import "MLCustomViewController.h"

#pragma mark - MLCustomViewController

@interface MLCustomViewController ()

@end

#pragma mark -

@implementation MLCustomViewController

#pragma mark Init / Dealloc

- (void)finishInitialize {
    [super finishInitialize];
    
    NSLog(@"-> %@: %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
}

- (void)dealloc {
    NSLog(@"-> %@: %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
}

#pragma mark View

- (void)loadView {
    [super loadView];
    
    NSLog(@"-> %@: %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.extendedLayoutIncludesOpaqueBars = NO;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.view.backgroundColor = [UIColor redColor];
    
    NSLog(@"-> %@: %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSLog(@"-> %@: %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    NSLog(@"-> %@: %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    NSLog(@"-> %@: %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    NSLog(@"-> %@: %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
}

- (void)updateViewConstraints {
    [super updateViewConstraints];
    
    NSLog(@"-> %@: %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    NSLog(@"-> %@: %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    NSLog(@"-> %@: %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
}

- (void)removeFromParentViewController {
    [super removeFromParentViewController];
    
    NSLog(@"-> %@: %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
}

@end
