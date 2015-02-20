//
//  UINavigationController+MLCustomConfiguration.m
//  ViewControllers
//
//  Created by Joachim Kret on 26/11/14.
//  Copyright (c) 2014 Joachim Kret. All rights reserved.
//

#import "UINavigationController+MLCustomConfiguration.h"

#import "MLCustomConfiguration.h"

@implementation UINavigationController (MLCustomConfiguration)

- (void)ml_pushViewController:(UIViewController *)viewController withConfiguration:(NSDictionary *)configuration animated:(BOOL)animated {
    NSParameterAssert(viewController);
    
    if (configuration && [viewController conformsToProtocol:@protocol(MLCustomConfiguration)]) {
        id <MLCustomConfiguration> controller = (id <MLCustomConfiguration>)viewController;
        
        if (!viewController.isViewLoaded && [controller respondsToSelector:@selector(finishInitializeWithConfiguration:)]) {
            [controller finishInitializeWithConfiguration:configuration];
        }
        
        if (!viewController.isViewLoaded) {
            [viewController view];
            
            if ([controller respondsToSelector:@selector(finishDidLoadWithConfiguration:)]) {
                [controller finishDidLoadWithConfiguration:configuration];
            }
        }
    }
    
    [self pushViewController:viewController animated:animated];
}

@end
