//
//  MLConfiguration.h
//  ViewControllers
//
//  Created by Joachim Kret on 01.05.2015.
//  Copyright (c) 2015 Joachim Kret. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MLConfiguration <NSObject>

@required
- (void)configureWithObject:(id)anObject context:(id)context;

@end
