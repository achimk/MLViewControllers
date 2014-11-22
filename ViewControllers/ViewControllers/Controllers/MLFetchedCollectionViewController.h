//
//  MLFetchedCollectionViewController.h
//  ViewControllers
//
//  Created by Joachim Kret on 22.11.2014.
//  Copyright (c) 2014 Joachim Kret. All rights reserved.
//

#import "MLCollectionViewController.h"

@interface MLFetchedCollectionViewController : MLCollectionViewController <NSFetchedResultsControllerDelegate>

@property (nonatomic, readonly, strong) NSFetchedResultsController * fetchedResultsController;
@property (nonatomic, readonly, assign, getter = isEmpty) BOOL empty;
@property (nonatomic ,readwrite, assign) MLChangeType changeType;

- (id)initWithFetchedResultsController:(NSFetchedResultsController *)fetchedResultsController;

- (void)setNeedsFetch;
- (BOOL)needsFetch;

- (void)fetchIfNeeded;
- (void)fetchIfVisible;
- (void)performFetch;

@end

@interface MLFetchedCollectionViewController (MLSubclassOnly)

//NSFetchedResultsController configuration methods
+ (Class)defaultFetchedResultsControllerClass;
- (NSString *)entityName;
- (NSManagedObjectContext *)managedObjectContext;
- (NSFetchRequest *)fetchRequest;
- (NSArray *)sortDescriptors;
- (NSPredicate *)predicate;
- (NSString *)sectionNameKeyPath;
- (NSString *)cacheName;

//NSFetchedResultsController observe methods
- (void)willCreateFetchedResultsController;
- (void)didCreateFetchedResultsController;

//NSIndexPath manipulation during update NSFetchedResultsController
- (NSIndexPath *)viewIndexPathForFetchedIndexPath:(NSIndexPath *)fetchedIndexPath;
- (NSIndexPath *)viewIndexPathForController:(NSFetchedResultsController *)controller fetchedIndexPath:(NSIndexPath *)fetchedIndexPath;

- (NSIndexPath *)fetchedIndexPathForViewIndexPath:(NSIndexPath *)viewIndexPath;
- (NSIndexPath *)fetchedIndexPathForController:(NSFetchedResultsController *)controller viewIndexPath:(NSIndexPath *)viewIndexPath;

- (id)objectForViewIndexPath:(NSIndexPath *)viewIndexPath;
- (id)objectForController:(NSFetchedResultsController *)controller viewIndexPath:(NSIndexPath *)viewIndexPath;

@end