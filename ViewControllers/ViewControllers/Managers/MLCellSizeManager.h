//
//  MLCellSizeManager.h
//  ViewControllers
//
//  Created by Joachim Kret on 28.04.2015.
//  Copyright (c) 2015 Joachim Kret. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MLCellConfiguration.h"

typedef void (^MLCellSizeManagerSizeBlock)(id cell, id anObject, NSIndexPath * indexPath);

@interface MLCellSizeManager : NSObject

@property (nonatomic, readwrite, assign) CGFloat cellHeightPadding; // Adds extra 1px height for table's cell divider, if not used you should setup it as 0 value.
@property (nonatomic, readwrite, assign) CGFloat overrideWidth; // Override cell width. Default static width is used.

- (void)registerCellClass:(Class <MLCellConfiguration>)cellClass withSizeBlock:(MLCellSizeManagerSizeBlock)sizeBlock;

- (CGSize)cellSizeForObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath;
- (CGSize)cellSizeForObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath withReuseIdentifier:(NSString *)reuseIdentifier;

- (void)invalidateCellSizeCache;
- (void)invalidateCellSizeCacheAtIndexPath:(NSIndexPath *)indexPath;
- (void)invalidateCellSizeCacheAtIndexPaths:(NSArray *)arrayOfIndexPaths;

@end
