//
//  MLFetchedResultsController.h
//  ViewControllers
//
//  Created by Joachim Kret on 08.03.2015.
//  Copyright (c) 2015 Joachim Kret. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "MLResultsControllerProtocol.h"

/*
 * Delete cache types, used when cache name is specified
 */
typedef NS_ENUM(NSUInteger, MLFetchedCacheDeleteRule) {
    MLFetchedCacheDeleteRuleDefault,        // On predicate or sort change
    MLFetchedCacheDeleteRuleNever,          // Delete cache never occurs
    MLFetchedCacheDeleteRuleAlways          // Delete cache occurs before every performFetch: method
};

@interface MLFetchedResultsController : NSObject <MLResultsController>

@property (nonatomic, readwrite, strong) NSPredicate * predicate;
@property (nonatomic, readwrite, strong) NSArray * sortDescriptors;
@property (nonatomic, readwrite, assign) MLFetchedCacheDeleteRule cacheDeleteRule;

- (instancetype)initWithFetchRequest:(NSFetchRequest *)fetchRequest managedObjectContext:(NSManagedObjectContext *)context sectionNameKeyPath:(NSString *)sectionNameKeyPath cacheName:(NSString *)name;

- (BOOL)fetchIfNeeded:(NSError **)error;
- (BOOL)performFetch:(NSError **)error;

@end
