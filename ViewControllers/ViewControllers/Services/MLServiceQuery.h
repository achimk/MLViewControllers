//
//  MLServiceQuery.h
//  ViewControllers
//
//  Created by Joachim Kret on 10.04.2015.
//  Copyright (c) 2015 Joachim Kret. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MLServiceQuery <NSObject>

@required
- (NSDictionary *)parameters;
- (Class)serializingClass;

@end
