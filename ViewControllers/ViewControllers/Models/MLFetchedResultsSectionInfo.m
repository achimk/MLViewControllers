//
//  MLFetchedResultsSectionInfo.m
//  ViewControllers
//
//  Created by Joachim Kret on 16.04.2015.
//  Copyright (c) 2015 Joachim Kret. All rights reserved.
//

#import "MLFetchedResultsSectionInfo.h"

@implementation MLFetchedResultsSectionInfo

@dynamic name;
@dynamic indexTitle;
@dynamic numberOfObjects;
@dynamic objects;

#pragma mark Init

- (instancetype)initWithFetchedResultsSectionInfo:(id <NSFetchedResultsSectionInfo>)section {
    NSParameterAssert(section);
    
    if (self = [super init]) {
        _section = section;
    }
    
    return self;
}

#pragma mark Accessors

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
