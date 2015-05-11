//
//  MLContainerViewController.m
//  ViewControllers
//
//  Created by Joachim Kret on 09.05.2015.
//  Copyright (c) 2015 Joachim Kret. All rights reserved.
//

#import "MLContainerViewController.h"

#pragma mark - MLContainerSegue

@implementation MLContainerSegue

- (void)perform {
    // Empty method - MLContainerViewController class handle all view controller actions
}

@end

#pragma mark - MLContainerViewController

@interface MLContainerViewController () {
    BOOL _containerViewConstraintsNeedsUpdate;
}

@property (nonatomic, readwrite, strong) IBOutlet UIView * containerView;

@end

#pragma mark -

@implementation MLContainerViewController

@dynamic selectedIndex;

+ (Class)defaultContainerViewClass {
    return [UIView class];
}

+ (UIEdgeInsets)defaultContainerViewInset {
    return UIEdgeInsetsZero;
}

#pragma mark Init

- (void)finishInitialize {
    [super finishInitialize];
    
    _containerViewConstraintsNeedsUpdate = NO;
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
    
    if (self.storyboard && self.segueIdentifiers) {
        [self setupViewControllersWithSegueIdentifiers:self.segueIdentifiers];
    }
}

#pragma mark Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [super prepareForSegue:segue sender:sender];
    
    if ([self.segueIdentifiers containsObject:segue.identifier] &&
        [sender isKindOfClass:[NSMutableArray class]]) {
        NSMutableArray * viewControllers = (NSMutableArray *)sender;
        
        if (viewControllers) {
            [viewControllers addObject:segue.destinationViewController];
        }
    }
}

#pragma mark Constraints

- (void)updateViewConstraints {
    [super updateViewConstraints];
    
    if (_containerViewConstraintsNeedsUpdate) {
        _containerViewConstraintsNeedsUpdate = NO;
        [self updateContainerViewConstraints];
    }
}

- (void)updateContainerViewConstraints {
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

#pragma mark Accessors

- (void)setContainerView:(UIView *)containerView {
    if (containerView != _containerView) {
        if (_containerView) {
            [_containerView removeFromSuperview];
        }
        
        _containerView = containerView;
        
        if (containerView && !containerView.superview && self.isViewLoaded) {
            _containerViewConstraintsNeedsUpdate = YES;
            containerView.translatesAutoresizingMaskIntoConstraints = NO;
            [self.view addSubview:containerView];
            [self.view setNeedsUpdateConstraints];
        }
    }
}

- (void)setSegueIdentifiers:(NSArray *)segueIdentifiers {
    _segueIdentifiers = [segueIdentifiers copy];
    
    if (self.isViewLoaded && self.storyboard) {
        [self setupViewControllersWithSegueIdentifiers:segueIdentifiers];
    }
}

- (void)setViewControllers:(NSArray *)viewControllers {
    _viewControllers = [viewControllers copy];
    self.selectedIndex = (viewControllers.count) ? 0 : NSNotFound;
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex {
    NSAssert1(selectedIndex < self.viewControllers.count, @"Set selected index %@ out of bounds", @(selectedIndex));
    self.selectedViewController = (NSNotFound != selectedIndex) ? self.viewControllers[selectedIndex] : nil;
}

- (NSUInteger)selectedIndex {
    return (self.selectedViewController) ? [self.viewControllers indexOfObject:self.selectedViewController] : NSNotFound;
}

- (void)setSelectedViewController:(UIViewController *)selectedViewController {
    NSAssert(!selectedViewController || [self.viewControllers containsObject:selectedViewController], @"Selected view controller should be supplied with view controllers array or be nil");
    
    if (selectedViewController != _selectedViewController) {
        UIViewController * previousViewController = _selectedViewController;
        _selectedViewController = selectedViewController;
        
        if (!self.isViewLoaded) {
            [self view];
        }
        
        BOOL ignoreAppearance = !self.isViewVisible;
        UIView * containerView = self.containerView;
        [self replaceViewController:previousViewController
                 withViewController:selectedViewController
                    inContainerView:containerView
                 ignoringAppearance:ignoreAppearance
                         completion:nil];
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

#pragma mark Private Methods

- (void)setupViewControllersWithSegueIdentifiers:(NSArray *)segueIdentifiers {
    NSMutableArray * viewControllers = [[NSMutableArray alloc] init];
 
    for (NSString * segueIdentifier in segueIdentifiers) {
        [self performSegueWithIdentifier:segueIdentifier sender:viewControllers];
    }

    self.viewControllers = (viewControllers.count) ? [NSArray arrayWithArray:viewControllers] : nil;
}

- (void)replaceViewController:(UIViewController *)existingViewController
           withViewController:(UIViewController *)newViewController
              inContainerView:(UIView *)containerView
           ignoringAppearance:(BOOL)ignoringAppearance
                   completion:(void (^)(void))completion {
    // Add initial view controller
    if (!existingViewController && newViewController) {
        [newViewController willMoveToParentViewController:self];
        
        if (!ignoringAppearance) {
            [newViewController beginAppearanceTransition:YES animated:NO];
        }
        
        [self addChildViewController:newViewController];
        newViewController.view.translatesAutoresizingMaskIntoConstraints = NO;
        [containerView addSubview:newViewController.view];
        
        NSDictionary * views = @{@"view" : newViewController.view};
        [containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|" options:kNilOptions metrics:nil views:views]];
        [containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view]|" options:kNilOptions metrics:nil views:views]];
        
        [newViewController didMoveToParentViewController:self];
        
        if (!ignoringAppearance) {
            [newViewController endAppearanceTransition];
        }
        
        if (completion) {
            completion();
        }
    }
    // Remove existing view controller
    else if (existingViewController && !newViewController) {
        [existingViewController willMoveToParentViewController:nil];
        
        if (!ignoringAppearance) {
            [existingViewController beginAppearanceTransition:NO animated:NO];
        }
        
        [existingViewController.view removeFromSuperview];
        [existingViewController removeFromParentViewController];
        [existingViewController didMoveToParentViewController:nil];
        
        if (!ignoringAppearance) {
            [existingViewController endAppearanceTransition];
        }
        
        if (completion) {
            completion();
        }
    }
    // Replace existing view controller with new view controller
    else if ((existingViewController != newViewController) && newViewController) {
        [newViewController willMoveToParentViewController:self];
        [existingViewController willMoveToParentViewController:nil];
        
        if (!ignoringAppearance) {
            [existingViewController beginAppearanceTransition:NO animated:NO];
        }
        
        [existingViewController.view removeFromSuperview];
        [existingViewController removeFromParentViewController];
        [existingViewController didMoveToParentViewController:nil];
        
        if (!ignoringAppearance) {
            [existingViewController endAppearanceTransition];
            [newViewController beginAppearanceTransition:YES animated:NO];
        }
        
        newViewController.view.translatesAutoresizingMaskIntoConstraints = NO;
        [self addChildViewController:newViewController];
        [containerView addSubview:newViewController.view];
        
        NSDictionary * views = @{@"view" : newViewController.view};
        [containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|" options:kNilOptions metrics:nil views:views]];
        [containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view]|" options:kNilOptions metrics:nil views:views]];
        
        [newViewController didMoveToParentViewController:self];
        
        if (!ignoringAppearance) {
            [newViewController endAppearanceTransition];
        }
        
        if (completion) {
            completion();
        }
    }
}

@end
