//
//  MLCellConfiguration.h
//  ViewControllers
//
//  Created by Joachim Kret on 02.04.2015.
//  Copyright (c) 2015 Joachim Kret. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MLCellConfiguration <NSObject>

@required

// Define reusable cell identifier.
+ (NSString *)reuseIdentifier;

// Define default nib name, used for register and dequeue nib cell.
+ (NSString *)nibName;

// Configure cell with object. This method should call cell configuration with MLCellConfigurationTypeDefault type.
- (void)configureWithObject:(id)anObject indexPath:(NSIndexPath *)indexPath;

@end
