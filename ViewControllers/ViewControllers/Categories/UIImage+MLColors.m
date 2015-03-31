//
//  UIImage+MLColors.m
//  ViewControllers
//
//  Created by Joachim Kret on 31.03.2015.
//  Copyright (c) 2015 Joachim Kret. All rights reserved.
//

#import "UIImage+MLColors.h"

@implementation UIImage (MLColors)

+ (UIImage *)ml_imageWithColor:(UIColor *)color {
    return [self ml_imageWithColor:color size:CGSizeMake(1.0f, 1.0f)];
}

+ (UIImage *)ml_imageWithColor:(UIColor *)color size:(CGSize)size {
    NSParameterAssert(color);
    NSAssert1(size.width && size.height, @"Invalid image size: %@", NSStringFromCGSize(size));
    
    CGRect rect = CGRectZero;
    rect.size = size;
    
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage * image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end
