//
//  MLServiceModel.h
//  ViewControllers
//
//  Created by Joachim Kret on 10.04.2015.
//  Copyright (c) 2015 Joachim Kret. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MLServiceModel <NSObject>

@required
+ (id)serviceModelFromDictionary:(NSDictionary *)dictionary error:(NSError **)error;
+ (NSArray *)serviceModelsFromArray:(NSArray *)array error:(NSError **)error;

@end
