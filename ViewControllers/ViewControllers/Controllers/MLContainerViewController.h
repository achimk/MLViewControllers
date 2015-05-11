//
//  MLContainerViewController.h
//  ViewControllers
//
//  Created by Joachim Kret on 09.05.2015.
//  Copyright (c) 2015 Joachim Kret. All rights reserved.
//

#import "MLViewController.h"
#import "MLAutorotation.h"

@interface MLContainerSegue : UIStoryboardSegue
@end

@interface MLContainerViewController : MLViewController <MLAutorotation>

@property (nonatomic, readonly, strong) IBOutlet UIView * containerView;
@property (nonatomic, readwrite, copy) NSArray * segueIdentifiers;
@property (nonatomic, readwrite, copy) NSArray * viewControllers;
@property (nonatomic, readwrite, strong) UIViewController * selectedViewController;
@property (nonatomic, readwrite, assign) NSUInteger selectedIndex;
@property (nonatomic, readwrite, assign) MLAutorotationMode autorotationMode;

@end

@interface MLContainerViewController (MLSubclassOnly)

+ (Class)defaultContainerViewClass;
+ (UIEdgeInsets)defaultContainerViewInset;

- (void)replaceViewController:(UIViewController *)existingViewController
           withViewController:(UIViewController *)newViewController
              inContainerView:(UIView *)containerView
           ignoringAppearance:(BOOL)ignoringAppearance
                   completion:(void (^)(void))completion;

@end