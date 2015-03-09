//
//  MLCollectionListController.m
//  ViewControllers
//
//  Created by Joachim Kret on 09.03.2015.
//  Copyright (c) 2015 Joachim Kret. All rights reserved.
//

#import "MLCollectionListController.h"

#pragma mark - MLCollectionListSectionInfo

@interface MLCollectionListSectionInfo : NSObject <MLResultsSectionInfo>

@property (nonatomic, readonly, strong) id <RZCollectionListSectionInfo> section;

- (instancetype)initWithCollectionListSectionInfo:(id <RZCollectionListSectionInfo>)section;

@end

#pragma mark -

@implementation MLCollectionListSectionInfo

#pragma mark Init

- (instancetype)initWithCollectionListSectionInfo:(id<RZCollectionListSectionInfo>)section {
    NSParameterAssert(section);
    
    if (self = [super init]) {
        _section = section;
    }
    
    return self;
}

#pragma mark MLResultsSectionInfo

- (NSString *)name {
    return self.section.name;
}

- (NSString *)indexTitle {
    return self.section.indexTitle;
}

- (NSUInteger)numberOfObjects {
    return self.section.numberOfObjects;
}

- (NSArray *)objects {
    return self.section.objects;
}

@end

#pragma mark - MLCollectionListController

@interface MLCollectionListController () <RZCollectionListObserver>

@end

#pragma mark -

@implementation MLCollectionListController

+ (instancetype)controllerWithCollectionList:(id <RZCollectionList>)collectionList {
    return [[[self class] alloc] initWithCollectionList:collectionList];
}

#pragma mark Init

- (instancetype)init {
    METHOD_USE_DESIGNATED_INIT;
    return nil;
}

- (instancetype)initWithCollectionList:(id <RZCollectionList>)collectionList {
    NSParameterAssert(collectionList);
    
    if (self = [super init]) {
        _collectionList = collectionList;
        [_collectionList addCollectionListObserver:self];
    }
    
    return self;
}

- (void)dealloc {
    [_collectionList removeCollectionListObserver:self];
}

#pragma mark MLResultsController

- (NSArray *)allObjects {
    return [self.collectionList listObjects];
}

- (NSArray *)sections {
    NSMutableArray * arrayOfSections = [[NSMutableArray alloc] init];
    NSArray * arrayOfCollectionListSections = self.collectionList.sections;
    for (id <RZCollectionListSectionInfo> section in arrayOfCollectionListSections) {
        id <MLResultsSectionInfo> collectionListSectionInfo = [[MLCollectionListSectionInfo alloc] initWithCollectionListSectionInfo:section];
        [arrayOfSections addObject:collectionListSectionInfo];
    }

    return [NSArray arrayWithArray:arrayOfSections];
}

- (id)objectAtIndexPath:(NSIndexPath *)indexPath {
    return [self.collectionList objectAtIndexPath:indexPath];
}

- (NSIndexPath *)indexPathForObject:(id)object {
    return [self.collectionList indexPathForObject:object];
}

#pragma mark RZCollectionListObserver

/**
 *  Called right before the collection list will change its contents.
 *
 *  @param collectionList the collection list that is about to change.
 */
- (void)collectionListWillChangeContent:(id<RZCollectionList>)collectionList {
    for (id <MLResultsControllerObserver> observer in self.arrayOfObservers) {
        [observer resultsControllerWillChangeContent:self];
    }
}

/**
 *  Called every time on object in a collection list changes.
 *
 *  @param collectionList The collection list that changed.
 *  @param object         The object that changed.
 *  @param indexPath      The original index path of the object.
 *  @param type           The RZCollectionListChangeType change type.
 *  @param newIndexPath   The new index path of the object.
 */
- (void)collectionList:(id<RZCollectionList>)collectionList didChangeObject:(id)object atIndexPath:(NSIndexPath*)indexPath forChangeType:(RZCollectionListChangeType)type newIndexPath:(NSIndexPath*)newIndexPath {

    for (id <MLResultsControllerObserver> observer in self.arrayOfObservers) {
        if ([observer respondsToSelector:@selector(resultsController:didChangeObject:atIndexPath:forChangeType:newIndexPath:)]) {
            [observer resultsController:self
                        didChangeObject:object
                            atIndexPath:indexPath
                          forChangeType:type
                           newIndexPath:newIndexPath];
        }
    }
}

/**
 *  Called every time a section in a collection list changes.
 *
 *  @param collectionList The collection list that changed.
 *  @param sectionInfo    The section that changed.
 *  @param sectionIndex   The index of the section that changed.
 *  @param type           The RZCollectionListChangeType change type.
 */
- (void)collectionList:(id<RZCollectionList>)collectionList didChangeSection:(id<RZCollectionListSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(RZCollectionListChangeType)type {
    id <MLResultsSectionInfo> collectionListSectionInfo = [[MLCollectionListSectionInfo alloc] initWithCollectionListSectionInfo:sectionInfo];

    for (id <MLResultsControllerObserver> observer in self.arrayOfObservers) {
        if ([observer respondsToSelector:@selector(resultsController:didChangeSection:atIndex:forChangeType:)]) {
            [observer resultsController:self
                       didChangeSection:collectionListSectionInfo
                                atIndex:sectionIndex
                          forChangeType:type];
        }
    }
}

/**
 *  Called right after the collection list changed its contents.
 *
 *  @param collectionList The collection list that changed its contents.
 */
- (void)collectionListDidChangeContent:(id<RZCollectionList>)collectionList {
    for (id <MLResultsControllerObserver> observer in self.arrayOfObservers) {
        [observer resultsControllerDidChangeContent:self];
    }
}

@end
