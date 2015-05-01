//
//  RZBaseCollectionList+MLResultsController.h
//  ViewControllers
//
//  Created by Joachim Kret on 01.05.2015.
//  Copyright (c) 2015 Joachim Kret. All rights reserved.
//

#import "RZBaseCollectionList.h"
#import "MLResultsControllerProtocol.h"

@interface RZBaseCollectionList (MLResultsController) <MLResultsController>

@property (nonatomic, readwrite, strong) NSPointerArray * arrayOfObservers;

@end
