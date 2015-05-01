//
//  RZBaseCollectionList+MLResultsController.m
//  ViewControllers
//
//  Created by Joachim Kret on 01.05.2015.
//  Copyright (c) 2015 Joachim Kret. All rights reserved.
//

#import "RZBaseCollectionList+MLResultsController.h"
#import "RZBaseCollectionList_Private.h"
#import <objc/runtime.h>
#import "MLRuntime.h"

static void * kArrayOfObserversAssociatedKey;

// Original method implementations to swizzle
static void (*ml_original_sendWillChangeContentNotifications)(id, SEL) = NULL;
static void (*ml_original_sendDidChangeContentNotifications)(id, SEL) = NULL;
static void (*ml_original_sendSectionNotifications)(id, SEL, NSArray *) = NULL;
static void (*ml_original_sendObjectNotifications)(id, SEL, NSArray *) = NULL;


// Swizzled method implementations
static void ml_swizzled_sendWillChangeContentNotifications(RZBaseCollectionList * self, SEL _cmd);
static void ml_swizzled_sendDidChangeContentNotifications(RZBaseCollectionList * self, SEL _cmd);
static void ml_swizzled_sendSectionNotifications(RZBaseCollectionList * self, SEL _cmd, NSArray * notifications);
static void ml_swizzled_sendObjectNotifications(RZBaseCollectionList * self, SEL _cmd, NSArray * notifications);

#pragma mark - RZBaseCollectionList (MLResultsController)

@implementation RZBaseCollectionList (MLResultsController)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ml_original_sendWillChangeContentNotifications = (void (*)(id, SEL))MLSwizzleSelector(self, @selector(sendWillChangeContentNotifications), (IMP)ml_swizzled_sendWillChangeContentNotifications);
        ml_original_sendDidChangeContentNotifications = (void (*)(id, SEL))MLSwizzleSelector(self, @selector(sendDidChangeContentNotifications), (IMP)ml_swizzled_sendDidChangeContentNotifications);
        ml_original_sendSectionNotifications = (void (*)(id, SEL, NSArray *))MLSwizzleSelector(self, @selector(sendSectionNotifications:), (IMP)ml_swizzled_sendSectionNotifications);
        ml_original_sendObjectNotifications = (void (*)(id, SEL, NSArray *))MLSwizzleSelector(self, @selector(sendObjectNotifications:), (IMP)ml_swizzled_sendObjectNotifications);
    });
}

#pragma mark Accessors

- (void)setArrayOfObservers:(NSPointerArray *)arrayOfObservers {
    objc_setAssociatedObject(self, &kArrayOfObserversAssociatedKey, arrayOfObservers, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSPointerArray *)arrayOfObservers {
    NSPointerArray * arrayOfObservers = objc_getAssociatedObject(self, &kArrayOfObserversAssociatedKey);
    
    if (!arrayOfObservers) {
        arrayOfObservers = [[NSPointerArray alloc] initWithOptions:NSPointerFunctionsWeakMemory | NSPointerFunctionsObjectPointerPersonality];
        objc_setAssociatedObject(self, &kArrayOfObserversAssociatedKey, arrayOfObservers, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    return arrayOfObservers;
}

- (void)addResultsControllerObserver:(id<MLResultsControllerObserver>)observer {
    NSParameterAssert(observer);
    [self.arrayOfObservers addPointer:(__bridge void *)observer];
}

- (void)removeResultsControllerObserver:(id<MLResultsControllerObserver>)observer {
    NSParameterAssert(observer);
    NSUInteger index = [self.arrayOfObservers.allObjects indexOfObject:observer];
    if (NSNotFound != index) {
        [self.arrayOfObservers removePointerAtIndex:index];
    }
}

- (NSArray *)allObjects {
    return [self listObjects];
}

#pragma mark Swizzled

static void ml_swizzled_sendWillChangeContentNotifications(RZBaseCollectionList * self, SEL _cmd) {
    // Call original implementation
    (*ml_original_sendWillChangeContentNotifications)(self, _cmd);
    
    // Call will change for MLResultsControllerObserver observers
    [self.arrayOfObservers compact];
    NSArray * arrayOfObservers = [self.arrayOfObservers allObjects];
    for (id <MLResultsControllerObserver> observer in arrayOfObservers) {
        if ([observer respondsToSelector:@selector(resultsControllerWillChangeContent:)]) {
            [observer resultsControllerWillChangeContent:self];
        }
    }
}

static void ml_swizzled_sendDidChangeContentNotifications(RZBaseCollectionList * self, SEL _cmd) {
    // Call did change for MLResultsControllerObserver observers
    [self.arrayOfObservers compact];
    NSArray * arrayOfObservers = [self.arrayOfObservers allObjects];
    for (id <MLResultsControllerObserver> observer in arrayOfObservers) {
        if ([observer respondsToSelector:@selector(resultsControllerDidChangeContent:)]) {
            [observer resultsControllerDidChangeContent:self];
        }
    }
    
    // Call original implementation
    (*ml_original_sendDidChangeContentNotifications)(self, _cmd);
}

static void ml_swizzled_sendSectionNotifications(RZBaseCollectionList * self, SEL _cmd, NSArray * notifications) {
    // Call original implementation
    (*ml_original_sendSectionNotifications)(self, _cmd, notifications);
    
    // Call section change for MLResultsControllerObserver observers
    [self.arrayOfObservers compact];
    NSArray * arrayOfObservers = [self.arrayOfObservers allObjects];
    [notifications enumerateObjectsUsingBlock:^(RZCollectionListSectionNotification * notification, NSUInteger idx, BOOL *stop) {
        for (id <MLResultsControllerObserver> observer in arrayOfObservers) {
            if ([observer respondsToSelector:@selector(resultsController:didChangeSection:atIndex:forChangeType:)]) {
                id <MLResultsSectionInfo> sectionInfo = (id <MLResultsSectionInfo>)notification.sectionInfo;
                NSUInteger sectionIndex = notification.sectionIndex;
                MLResultsChangeType type = notification.type;
                
                [observer resultsController:self
                           didChangeSection:sectionInfo
                                    atIndex:sectionIndex
                              forChangeType:type];
            }
        }
    }];
}

static void ml_swizzled_sendObjectNotifications(RZBaseCollectionList * self, SEL _cmd, NSArray * notifications) {
    // Call original implementation
    (*ml_original_sendObjectNotifications)(self, _cmd, notifications);
    
    // Call object change for MLResultsControllerObserver observers
    [self.arrayOfObservers compact];
    NSArray * arrayOfObservers = [self.arrayOfObservers allObjects];
    [notifications enumerateObjectsUsingBlock:^(RZCollectionListObjectNotification * notification, NSUInteger idx, BOOL *stop) {
        for (id <MLResultsControllerObserver> observer in arrayOfObservers) {
            if ([observer respondsToSelector:@selector(resultsController:didChangeObject:atIndexPath:forChangeType:newIndexPath:)]) {
                id anObject = notification.object;
                NSIndexPath * indexPath = notification.indexPath;
                NSIndexPath * newIndexPath = notification.nuIndexPath;
                MLResultsChangeType type = notification.type;
                
                [observer resultsController:self
                            didChangeObject:anObject
                                atIndexPath:indexPath
                              forChangeType:type
                               newIndexPath:newIndexPath];
            }
        }
    }];
}

@end
