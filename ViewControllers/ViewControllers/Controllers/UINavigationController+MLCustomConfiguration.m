//
//  UINavigationController+MLCustomConfiguration.m
//  ViewControllers
//
//  Created by Joachim Kret on 26/11/14.
//  Copyright (c) 2014 Joachim Kret. All rights reserved.
//

#import "UINavigationController+MLCustomConfiguration.h"
#import "MLConfiguration.h"

@implementation UINavigationController (MLCustomConfiguration)

- (void)ml_pushViewController:(UIViewController *)viewController withObject:(id)anObject context:(id)context animated:(BOOL)animated {
    NSParameterAssert(viewController);
    
    if ([viewController conformsToProtocol:@protocol(MLConfiguration)]) {
        if (!viewController.isViewLoaded) {
            [viewController view];
        }
        
        [(id <MLConfiguration>)viewController configureWithObject:anObject context:context];
    }
    
    [self pushViewController:viewController animated:animated];
}

@end
