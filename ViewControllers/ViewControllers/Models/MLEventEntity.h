//
//  MLEventEntity.h
//  ViewControllers
//
//  Created by Joachim Kret on 29.03.2015.
//  Copyright (c) 2015 Joachim Kret. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface MLEventEntity : NSManagedObject

@property (nonatomic, retain) NSDate * timestamp;

@end
