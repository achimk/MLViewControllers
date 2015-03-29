//
//  MLDataStack.h
//  ViewControllers
//
//  Created by Joachim Kret on 29.03.2015.
//  Copyright (c) 2015 Joachim Kret. All rights reserved.
//

#import "MLInMemoryCoreDataStack.h"

@interface MLDataStack : MLInMemoryCoreDataStack

@property (nonatomic, readonly, strong) NSManagedObjectContext * savingContext;     // persistent context
@property (nonatomic, readonly, strong) NSManagedObjectContext * mainContext;       // UI updates

@end
