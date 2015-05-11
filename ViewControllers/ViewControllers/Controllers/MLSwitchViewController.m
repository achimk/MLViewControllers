//
//  MLSwitchViewController.m
//  ViewControllers
//
//  Created by Joachim Kret on 22.11.2014.
//  Copyright (c) 2014 Joachim Kret. All rights reserved.
//

#import "MLSwitchViewController.h"

#pragma mark - MLSwitchViewController

@interface MLSwitchViewController () {
    BOOL _containerConstraintsNeedsUpdate;
}

@property (nonatomic, readwrite, strong) IBOutlet UIView * containerView;
@property (nonatomic, readwrite, assign) BOOL forwardSelectedViewControllerAppearance;

@end

#pragma mark -

@implementation MLSwitchViewController

+ (Class)defaultContainerViewClass {
    return [UIView class];
}

+ (UIEdgeInsets)defaultContainerViewInset {
    return UIEdgeInsetsZero;
}

#pragma mark Init

- (void)finishInitialize {
    [super finishInitialize];
    
    _autorotationMode = MLAutorotationModeContainer;
}

#pragma mark View

- (void)loadView {
    [super loadView];
    
    if (!self.isViewLoaded) {
        self.view = [[UIView alloc] init];
    }
    
    if (!_containerView) {
        self.containerView = [[[[self class] defaultContainerViewClass] alloc] init];
        self.containerView.backgroundColor = [UIColor whiteColor];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.viewControllers.count && !self.selectedViewController) {
        self.selectedIndex = 0;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.forwardSelectedViewControllerAppearance) {
        [self.selectedViewController beginAppearanceTransition:YES animated:animated];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (self.forwardSelectedViewControllerAppearance) {
        [self.selectedViewController endAppearanceTransition];
        self.forwardSelectedViewControllerAppearance = NO;
    }
}

#pragma mark Constraints

- (void)updateViewConstraints {
    [super updateViewConstraints];
    
    if (_containerConstraintsNeedsUpdate) {
        _containerConstraintsNeedsUpdate = NO;
        
        UIEdgeInsets inset = [[self class] defaultContainerViewInset];
        NSDictionary * sizes = @{@"top"             : @(inset.top),
                                 @"bottom"          : @(inset.bottom),
                                 @"left"            : @(inset.left),
                                 @"right"           : @(inset.right)};
        NSDictionary * views = @{@"topGuide"        : self.topLayoutGuide,
                                 @"containerView"   : self.containerView};
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[topGuide]-(top)-[containerView]-(bottom)-|" options:kNilOptions metrics:sizes views:views]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(left)-[containerView]-(right)-|" options:kNilOptions metrics:sizes views:views]];
    }
}

#pragma mark Accessors

- (void)setContainerView:(UIView *)containerView {
    if (containerView != _containerView) {
        if (_containerView) {
            [_containerView removeFromSuperview];
        }
        
        _containerView = containerView;
        
        if (containerView && !containerView.superview && self.isViewLoaded) {
            _containerConstraintsNeedsUpdate = YES;
            containerView.translatesAutoresizingMaskIntoConstraints = NO;
            [self.view addSubview:containerView];
            [self.view setNeedsUpdateConstraints];
        }
    }
}

- (void)setViewControllers:(NSArray *)viewControllers {
    _viewControllers = [viewControllers copy];
    
    if (self.isViewLoaded && _viewControllers.count) {
        self.selectedIndex = 0;
    }
    else {
        self.selectedIndex = NSNotFound;
    }
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex {
    NSAssert1(NSNotFound ==selectedIndex || (0 <= selectedIndex && selectedIndex < self.viewControllers.count), @"Set selected index %@ out of bounds", @(selectedIndex));
    self.selectedViewController = (NSNotFound != selectedIndex) ? self.viewControllers[selectedIndex] : nil;
}

- (NSUInteger)selectedIndex {
    return (self.selectedViewController) ? [self.viewControllers indexOfObject:self.selectedViewController] : NSNotFound;
}

- (void)setSelectedViewController:(UIViewController *)selectedViewController {
    if (selectedViewController != _selectedViewController &&
        (!selectedViewController || [self.viewControllers containsObject:selectedViewController])) {
        
        UIViewController * previousViewController = _selectedViewController;
        _selectedViewController = selectedViewController;
        
        if (self.isViewLoaded) {
            self.forwardSelectedViewControllerAppearance = !self.isViewVisible;
            [self replaceViewController:previousViewController
                     withViewController:selectedViewController
                        inContainerView:self.containerView
                     ignoringAppearance:!self.isViewVisible
                             completion:nil];
        }
    }
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
            UIViewController * topViewController = self.selectedViewController;
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

#pragma mark Subclass Methods

#warning Refactor swap view controllers method!
- (void)replaceViewController:(UIViewController *)existingViewController
           withViewController:(UIViewController *)newViewController
              inContainerView:(UIView *)containerView
           ignoringAppearance:(BOOL)ignoringAppearance
                   completion:(void (^)(void))completion {
    NSParameterAssert(containerView);
    
    if (ignoringAppearance) {
        // Add initial view controller
        if (!existingViewController && newViewController) {
            [newViewController willMoveToParentViewController:self];
            [self addChildViewController:newViewController];
            newViewController.view.translatesAutoresizingMaskIntoConstraints = NO;
            [containerView addSubview:newViewController.view];
            [newViewController didMoveToParentViewController:self];
            
            NSDictionary * views = @{@"view" : newViewController.view};
            [containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|" options:kNilOptions metrics:nil views:views]];
            [containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view]|" options:kNilOptions metrics:nil views:views]];
            
            if (completion) {
                completion();
            }
        }
        // Remove existing view controller
        else if (existingViewController && !newViewController) {
            [existingViewController willMoveToParentViewController:nil];
            [existingViewController.view removeFromSuperview];
            [existingViewController removeFromParentViewController];
            [existingViewController didMoveToParentViewController:nil];
            
            if (completion) {
                completion();
            }
            
        }
        // Replace existing view controller with new view controller
        else if ((existingViewController != newViewController) && newViewController) {
            [newViewController willMoveToParentViewController:self];
            [existingViewController willMoveToParentViewController:nil];
            [existingViewController.view removeFromSuperview];
            [existingViewController removeFromParentViewController];
            [existingViewController didMoveToParentViewController:nil];
            newViewController.view.translatesAutoresizingMaskIntoConstraints = NO;
            [self addChildViewController:newViewController];
            [containerView addSubview:newViewController.view];
            
            NSDictionary * views = @{@"view" : newViewController.view};
            [containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|" options:kNilOptions metrics:nil views:views]];
            [containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view]|" options:kNilOptions metrics:nil views:views]];
            
            [newViewController didMoveToParentViewController:self];
            
            if (completion) {
                completion();
            }
        }
    }
    else {
        // Add initial view controller
        if (!existingViewController && newViewController) {
            [newViewController willMoveToParentViewController:self];
            [newViewController beginAppearanceTransition:YES animated:NO];
            [self addChildViewController:newViewController];
            newViewController.view.translatesAutoresizingMaskIntoConstraints = NO;
            [containerView addSubview:newViewController.view];
            
            NSDictionary * views = @{@"view" : newViewController.view};
            [containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|" options:kNilOptions metrics:nil views:views]];
            [containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view]|" options:kNilOptions metrics:nil views:views]];
            
            [newViewController didMoveToParentViewController:self];
            [newViewController endAppearanceTransition];
            
            if (completion) {
                completion();
            }
        }
        // Remove existing view controller
        else if (existingViewController && !newViewController) {
            [existingViewController willMoveToParentViewController:nil];
            [existingViewController beginAppearanceTransition:NO animated:NO];
            [existingViewController.view removeFromSuperview];
            [existingViewController removeFromParentViewController];
            [existingViewController didMoveToParentViewController:nil];
            [existingViewController endAppearanceTransition];
            
            if (completion) {
                completion();
            }
        }
        // Replace existing view controller with new view controller
        else if ((existingViewController != newViewController) && newViewController) {
            [newViewController willMoveToParentViewController:self];
            [existingViewController willMoveToParentViewController:nil];
            [existingViewController beginAppearanceTransition:NO animated:NO];
            [existingViewController.view removeFromSuperview];
            [existingViewController removeFromParentViewController];
            [existingViewController didMoveToParentViewController:nil];
            [existingViewController endAppearanceTransition];
            [newViewController beginAppearanceTransition:YES animated:NO];
            newViewController.view.translatesAutoresizingMaskIntoConstraints = NO;
            [self addChildViewController:newViewController];
            [containerView addSubview:newViewController.view];
            
            NSDictionary * views = @{@"view" : newViewController.view};
            [containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|" options:kNilOptions metrics:nil views:views]];
            [containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view]|" options:kNilOptions metrics:nil views:views]];
            
            [newViewController didMoveToParentViewController:self];
            [newViewController endAppearanceTransition];
            
            if (completion) {
                completion();
            }
        }
    }
}

@end
