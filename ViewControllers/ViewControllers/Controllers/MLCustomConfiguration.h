//
//  MLCustomConfiguration.h
//  ViewControllers
//
//  Created by Joachim Kret on 22.11.2014.
//  Copyright (c) 2014 Joachim Kret. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MLCustomConfiguration <NSObject>

@optional
- (void)finishInitializeWithConfiguration:(NSDictionary *)dictionary;
- (void)finishDidLoadWithConfiguration:(NSDictionary *)dictionary;

@end
