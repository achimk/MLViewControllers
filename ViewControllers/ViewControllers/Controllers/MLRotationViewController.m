//
//  MLRotationViewController.m
//  ViewControllers
//
//  Created by Joachim Kret on 20.02.2015.
//  Copyright (c) 2015 Joachim Kret. All rights reserved.
//

#import "MLRotationViewController.h"
#import "MLAutorotation.h"

#define LOG_APPEARANCE  0

typedef NS_ENUM (NSUInteger, MLSection) {
    MLSectionAutorotationMode,
    MLSectionOrientationMask,
    MLSectionCount
};

#pragma mark - MLRotationViewController

@interface MLRotationViewController ()

@property (nonatomic, readwrite, assign) MLAutorotationMode mode;
@property (nonatomic, readwrite, assign) UIInterfaceOrientationMask mask;

@property (nonatomic, readonly, strong) NSDictionary * dictionaryOfModes;
@property (nonatomic, readonly, strong) NSDictionary * dictionaryOfMasks;

@end

#pragma mark -

@implementation MLRotationViewController

#pragma mark Init

- (void)finishInitialize {
    [super finishInitialize];
    
    _mode = MLAutorotationModeContainer;
    _mask = UIInterfaceOrientationMaskAll;
    
    _dictionaryOfModes = @{@(MLAutorotationModeContainer)               : @"Container only",
                           @(MLAutorotationModeContainerAndTopChildren) : @"Container and top children",
                           @(MLAutorotationModeContainerAndAllChildren) : @"Container and all children"};
    
    _dictionaryOfMasks = @{@(UIInterfaceOrientationUnknown)             : @"None",
                           @(UIInterfaceOrientationPortrait)            : @"Portrait",
                           @(UIInterfaceOrientationLandscapeLeft)       : @"Landscape Left",
                           @(UIInterfaceOrientationLandscapeRight)      : @"Landscape Right",
                           @(UIInterfaceOrientationPortraitUpsideDown)  : @"Upside Down"};
}

#pragma mark View

- (void)viewDidLoad {
    [super viewDidLoad];
    
#if LOG_APPEARANCE
    NSLog(@"-> %p, %@, %@", self, NSStringFromClass([self class]), NSStringFromSelector(_cmd));
#endif
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.autorotationController.autorotationMode = self.mode;
}

#if LOG_APPEARANCE
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSLog(@"-> %p, %@, %@", self, NSStringFromClass([self class]), NSStringFromSelector(_cmd));
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    NSLog(@"-> %p, %@, %@", self, NSStringFromClass([self class]), NSStringFromSelector(_cmd));
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    NSLog(@"-> %p, %@, %@", self, NSStringFromClass([self class]), NSStringFromSelector(_cmd));
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    NSLog(@"-> %p, %@, %@", self, NSStringFromClass([self class]), NSStringFromSelector(_cmd));
}
#endif

#pragma mark Accessors

- (NSString *)title {
    return ([super title]) ?: @"Rotation";
}

- (UIViewController <MLAutorotation> *)autorotationController {
    return (self.parentViewController && [self.parentViewController conformsToProtocol:@protocol(MLAutorotation)]) ? (UIViewController <MLAutorotation> *)self.parentViewController : nil;
}

#pragma mark Rotation

- (BOOL)shouldAutorotate {
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
    return self.mask;
}

#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case MLSectionAutorotationMode: {
            self.mode = indexPath.row;
            self.autorotationController.autorotationMode = self.mode;
        } break;
            
        case MLSectionOrientationMask: {
            [self toggleMaskForOrientation:indexPath.row];
        } break;
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    [self reloadData];
}

#pragma mark UITableDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * cellIdentifier = @"CellIdentifier";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    switch (indexPath.section) {
        case MLSectionAutorotationMode: {
            cell.textLabel.text = self.dictionaryOfModes[@(indexPath.row)];
            cell.accessoryType = (indexPath.row == self.mode) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
        } break;
            
        case MLSectionOrientationMask: {
            cell.textLabel.text = self.dictionaryOfMasks[@(indexPath.row)];
            cell.accessoryType = ([self hasMaskForOrientation:indexPath.row]) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
        } break;
    }
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return MLSectionCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case MLSectionAutorotationMode: {
            return self.dictionaryOfModes.allKeys.count;
        }
        case MLSectionOrientationMask: {
            return self.dictionaryOfMasks.allKeys.count;
        }
        default: {
            return 0;
        }
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    static NSDictionary * headerTitles = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        headerTitles = @{@(MLSectionAutorotationMode)   : @"Autorotation",
                         @(MLSectionOrientationMask)    : @"Orientation"};
    });
    
    return headerTitles[@(section)];
}

#pragma mark Private Methods

- (void)toggleMaskForOrientation:(UIInterfaceOrientation)orientation {
    switch (orientation) {
        case UIInterfaceOrientationUnknown: {
            self.mask &= ~UIInterfaceOrientationMaskAll;
        } break;
            
        case UIInterfaceOrientationPortrait: {
            if (self.mask & UIInterfaceOrientationMaskPortrait) {
                self.mask &= ~UIInterfaceOrientationMaskPortrait;
            }
            else {
                self.mask |= UIInterfaceOrientationMaskPortrait;
            }
        } break;
            
        case UIInterfaceOrientationLandscapeLeft: {
            if (self.mask & UIInterfaceOrientationMaskLandscapeLeft) {
                self.mask &= ~UIInterfaceOrientationMaskLandscapeLeft;
            }
            else {
                self.mask |= UIInterfaceOrientationMaskLandscapeLeft;
            }
        } break;
            
        case UIInterfaceOrientationLandscapeRight: {
            if (self.mask & UIInterfaceOrientationMaskLandscapeRight) {
                self.mask &= ~UIInterfaceOrientationMaskLandscapeRight;
            }
            else {
                self.mask |= UIInterfaceOrientationMaskLandscapeRight;
            }
        } break;
            
        case UIInterfaceOrientationPortraitUpsideDown: {
            if (self.mask & UIInterfaceOrientationMaskPortraitUpsideDown) {
                self.mask &= ~UIInterfaceOrientationMaskPortraitUpsideDown;
            }
            else {
                self.mask |= UIInterfaceOrientationMaskPortraitUpsideDown;
            }
        } break;
    }
}

- (BOOL)hasMaskForOrientation:(UIInterfaceOrientation)orientation {
    switch (orientation) {
        case UIInterfaceOrientationUnknown: {
            return !(self.mask & UIInterfaceOrientationMaskAll);
        }
        case UIInterfaceOrientationPortrait: {
            return (self.mask & UIInterfaceOrientationMaskPortrait);
        }
        case UIInterfaceOrientationLandscapeLeft: {
            return (self.mask & UIInterfaceOrientationMaskLandscapeLeft);
        }
        case UIInterfaceOrientationLandscapeRight: {
            return (self.mask & UIInterfaceOrientationMaskLandscapeRight);
        }
        case UIInterfaceOrientationPortraitUpsideDown: {
            return (self.mask & UIInterfaceOrientationMaskPortraitUpsideDown);
        }
    }
}

@end
