//
//  MLFetchedResultsSectionInfo.h
//  ViewControllers
//
//  Created by Joachim Kret on 16.04.2015.
//  Copyright (c) 2015 Joachim Kret. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "MLResultsControllerProtocol.h"

@interface MLFetchedResultsSectionInfo : NSObject <MLResultsSectionInfo>

@property (nonatomic, readonly, strong) id <NSFetchedResultsSectionInfo> section;

- (instancetype)initWithFetchedResultsSectionInfo:(id <NSFetchedResultsSectionInfo>)section;

@end
