//
//  RZArrayCollectionList+MLResultsController.m
//  ViewControllers
//
//  Created by Joachim Kret on 01.05.2015.
//  Copyright (c) 2015 Joachim Kret. All rights reserved.
//

#import "RZArrayCollectionList+MLResultsController.h"
#import "RZBaseCollectionList+MLResultsController.h"
#import <objc/runtime.h>
#import "MLRuntime.h"

// Original method implementations to swizzle
static void (*ml_original_sendDidChangeSectionNotification)(id, SEL, id, NSUInteger, RZCollectionListChangeType) = NULL;
static void (*ml_original_sendDidChangeObjectNotification)(id, SEL, id, NSIndexPath *, RZCollectionListChangeType, NSIndexPath *) = NULL;

// Swizzled method implementations
static void ml_swizzled_sendDidChangeSectionNotification(RZArrayCollectionList * self, SEL _cmd, id sectionInfo, NSUInteger sectionIndex, RZCollectionListChangeType type);
static void ml_swizzled_sendDidChangeObjectNotification(RZArrayCollectionList * self, SEL _cmd, id anObject, NSIndexPath * indexPath, RZCollectionListChangeType type, NSIndexPath * newIndexPath);

#pragma mark - RZArrayCollectionList ()

@interface RZArrayCollectionList ()

- (void)sendDidChangeSectionNotification:(id<RZCollectionListSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(RZCollectionListChangeType)type;
- (void)sendDidChangeObjectNotification:(id)object atIndexPath:(NSIndexPath*)indexPath forChangeType:(RZCollectionListChangeType)type newIndexPath:(NSIndexPath*)newIndexPath;

@end

#pragma mark - RZArrayCollectionList (MLResultsController)

@implementation RZArrayCollectionList (MLResultsController)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ml_original_sendDidChangeSectionNotification = (void (*)(id, SEL, id, NSUInteger, RZCollectionListChangeType))MLSwizzleSelector(self, @selector(sendDidChangeSectionNotification:atIndex:forChangeType:), (IMP)ml_swizzled_sendDidChangeSectionNotification);
        ml_original_sendDidChangeObjectNotification = (void (*)(id, SEL, id, NSIndexPath *, RZCollectionListChangeType, NSIndexPath *))MLSwizzleSelector(self, @selector(sendDidChangeObjectNotification:atIndexPath:forChangeType:newIndexPath:), (IMP)ml_swizzled_sendDidChangeObjectNotification);
    });
}

#pragma mark Swizzled

static void ml_swizzled_sendDidChangeSectionNotification(RZArrayCollectionList * self, SEL _cmd, id sectionInfo, NSUInteger sectionIndex, RZCollectionListChangeType type) {
    // Call original implementation
    (*ml_original_sendDidChangeSectionNotification)(self, _cmd, sectionInfo, sectionIndex, type);
    
    // Call section change for MLResultsControllerObserver observers
    [self.arrayOfObservers compact];
    NSArray * arrayOfObservers = [self.arrayOfObservers allObjects];
    for (id <MLResultsControllerObserver> observer in arrayOfObservers) {
        if ([observer respondsToSelector:@selector(resultsController:didChangeSection:atIndex:forChangeType:)]) {
            [observer resultsController:self
                       didChangeSection:sectionInfo
                                atIndex:sectionIndex
                          forChangeType:type];
        }
    }
}

static void ml_swizzled_sendDidChangeObjectNotification(RZArrayCollectionList * self, SEL _cmd, id anObject, NSIndexPath * indexPath, RZCollectionListChangeType type, NSIndexPath * newIndexPath) {
    // Call original implementation
    (*ml_original_sendDidChangeObjectNotification)(self, _cmd, anObject, indexPath, type, newIndexPath);
    
    // call object change for MLResultsControllerObserver observers
    [self.arrayOfObservers compact];
    NSArray * arrayOfObservers = [self.arrayOfObservers allObjects];
    for (id <MLResultsControllerObserver> observer in arrayOfObservers) {
        if ([observer respondsToSelector:@selector(resultsController:didChangeObject:atIndexPath:forChangeType:newIndexPath:)]) {
            [observer resultsController:self
                        didChangeObject:anObject
                            atIndexPath:indexPath
                          forChangeType:type
                           newIndexPath:newIndexPath];
        }
    }
}

@end
