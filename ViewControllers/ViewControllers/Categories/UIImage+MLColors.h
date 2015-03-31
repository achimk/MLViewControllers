//
//  UIImage+MLColors.h
//  ViewControllers
//
//  Created by Joachim Kret on 31.03.2015.
//  Copyright (c) 2015 Joachim Kret. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (MLColors)

+ (UIImage *)ml_imageWithColor:(UIColor *)color;
+ (UIImage *)ml_imageWithColor:(UIColor *)color size:(CGSize)size;

@end
