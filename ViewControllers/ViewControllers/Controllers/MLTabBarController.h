//
//  MLTabBarController.h
//  ViewControllers
//
//  Created by Joachim Kret on 22.11.2014.
//  Copyright (c) 2014 Joachim Kret. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MLAutorotation.h"

@interface MLTabBarController : UITabBarController <MLAutorotation>

@property (nonatomic, readonly, assign) BOOL appearsFirstTime;
@property (nonatomic, readonly, assign, getter = isViewVisible) BOOL viewVisible;
@property (nonatomic, readwrite, assign) MLAutorotationMode autorotationMode;

@end

@interface MLTabBarController (MLSubclassOnly)

- (void)finishInitialize NS_REQUIRES_SUPER;

@end
