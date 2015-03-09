//
//  MLBaseResultsController.h
//  ViewControllers
//
//  Created by Joachim Kret on 09.03.2015.
//  Copyright (c) 2015 Joachim Kret. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MLResultsControllerProtocol.h"

@interface MLBaseResultsController : NSObject <MLResultsController>

@property (nonatomic, readonly, strong) NSArray * arrayOfObservers;

@end
