//
//  MLResultsControllerProtocol.h
//  ViewControllers
//
//  Created by Joachim Kret on 07.03.2015.
//  Copyright (c) 2015 Joachim Kret. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MLResultsControllerObserver;

#pragma mark - MLResultsSectionInfo

@protocol MLResultsSectionInfo <NSObject>

@property (nonatomic, readonly, strong) NSString * name;
@property (nonatomic, readonly, strong) NSString * indexTitle;
@property (nonatomic, readonly, assign) NSUInteger numberOfObjects;
@property (nonatomic, readonly, strong) NSArray * objects;

@end

#pragma mark - MLResultsControllerProtocol

@protocol MLResultsController <NSObject>

@property (nonatomic, readonly, strong) NSArray * allObjects;
@property (nonatomic, readonly, strong) NSArray * sections;

- (id)objectAtIndexPath:(NSIndexPath *)indexPath;
- (NSIndexPath *)indexPathForObject:(id)object;

- (void)addResultsControllerObserver:(id <MLResultsControllerObserver>)observer;
- (void)removeResultsControllerObserver:(id <MLResultsControllerObserver>)observer;

@end

#pragma mark - MLResultsControllerDelegate

@protocol MLResultsControllerObserver <NSObject>

typedef NS_ENUM(NSUInteger, MLResultsChangeType) {
    MLResultsChangeTypeInsert   = 1,
    MLResultsChangeTypeDelete   = 2,
    MLResultsChangeTypeMove     = 3,
    MLResultsChangeTypeUpdate   = 4
};

@optional
- (void)resultsControllerWillChangeContent:(id <MLResultsController>)resultsController;
- (void)resultsController:(id <MLResultsController>)resultsController didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(MLResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath;
- (void)resultsController:(id <MLResultsController>)resultsController didChangeSection:(id <MLResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(MLResultsChangeType)type;
- (void)resultsControllerDidChangeContent:(id <MLResultsController>)resultsController;

@end
