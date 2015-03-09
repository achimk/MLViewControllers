//
//  MLCollectionListController.h
//  ViewControllers
//
//  Created by Joachim Kret on 09.03.2015.
//  Copyright (c) 2015 Joachim Kret. All rights reserved.
//

#import "MLBaseResultsController.h"
#import "RZCollectionList.h"

@interface MLCollectionListController : MLBaseResultsController

@property (nonatomic, readonly, strong) id <RZCollectionList> collectionList;

+ (instancetype)controllerWithCollectionList:(id <RZCollectionList>)collectionList;

- (instancetype)initWithCollectionList:(id <RZCollectionList>)collectionList;

@end
