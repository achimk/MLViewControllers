//
//  UINavigationController+MLCustomConfiguration.h
//  ViewControllers
//
//  Created by Joachim Kret on 26/11/14.
//  Copyright (c) 2014 Joachim Kret. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UINavigationController (MLCustomConfiguration)

- (void)ml_pushViewController:(UIViewController *)viewController withConfiguration:(NSDictionary *)configuration animated:(BOOL)animated;

@end
