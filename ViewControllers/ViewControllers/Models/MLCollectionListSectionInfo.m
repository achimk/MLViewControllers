//
//  MLCollectionListSectionInfo.m
//  ViewControllers
//
//  Created by Joachim Kret on 16.04.2015.
//  Copyright (c) 2015 Joachim Kret. All rights reserved.
//

#import "MLCollectionListSectionInfo.h"

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
