//
//  MLHTTPServiceOperation.h
//  ViewControllers
//
//  Created by Joachim Kret on 10.04.2015.
//  Copyright (c) 2015 Joachim Kret. All rights reserved.
//

#import "MLAsynchronousOperation.h"
#import "AFHTTPRequestOperation.h"
#import "MLServiceQuery.h"

@interface MLHTTPServiceOperation : MLAsynchronousOperation

@property (nonatomic, readonly, strong) AFHTTPRequestOperation * httpRequestOperation;
@property (nonatomic, readonly, strong) id <MLServiceQuery> query;

- (instancetype)initWithHTTPOperation:(AFHTTPRequestOperation *)operation query:(id <MLServiceQuery>)query;
- (instancetype)initWithIdentifier:(NSString *)identifier HTTPRequestOperation:(AFHTTPRequestOperation *)operation query:(id <MLServiceQuery>)query;

@end
