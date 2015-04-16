//
//  MLCollectionListSectionInfo.h
//  ViewControllers
//
//  Created by Joachim Kret on 16.04.2015.
//  Copyright (c) 2015 Joachim Kret. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MLResultsControllerProtocol.h"
#import "RZCollectionList.h"

@interface MLCollectionListSectionInfo : NSObject <MLResultsSectionInfo>

@property (nonatomic, readonly, strong) id <RZCollectionListSectionInfo> section;

- (instancetype)initWithCollectionListSectionInfo:(id <RZCollectionListSectionInfo>)section;

@end
