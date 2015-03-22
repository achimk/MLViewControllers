//
//  MLLoadToken.m
//  ViewControllers
//
//  Created by Joachim Kret on 22.03.2015.
//  Copyright (c) 2015 Joachim Kret. All rights reserved.
//

#import "MLLoadToken.h"

#pragma mark - MLLoadToken

@interface MLLoadToken ()

@property (nonatomic, readwrite, assign) MLLoadTokenState state;
@property (nonatomic, readwrite, strong) NSMutableArray * arrayOfSuccessHandlers;
@property (nonatomic, readwrite, strong) NSMutableArray * arrayOfFailureHandlers;

@end

#pragma mark -

@implementation MLLoadToken

+ (instancetype)token {
    return [[MLLoadToken alloc] init];
}

#pragma mark Init

- (instancetype)init {
    if (self = [super init]) {
        _state = MLLoadTokenStateReady;
        _arrayOfSuccessHandlers = [[NSMutableArray alloc] init];
        _arrayOfFailureHandlers = [[NSMutableArray alloc] init];
    }
    
    return self;
}

#pragma mark Handlers Managment

- (void)addSuccessHandler:(void (^)(id responseObjects))handler {
    NSParameterAssert(handler);
    
    @synchronized(self) {
        if (MLLoadTokenStateReady == self.state) {
            [self.arrayOfSuccessHandlers addObject:handler];
        }
    }
}

- (void)addFailureHandler:(void (^)(NSError * error))handler {
    NSParameterAssert(handler);
    
    @synchronized(self) {
        if (MLLoadTokenStateReady == self.state) {
            [self.arrayOfFailureHandlers addObject:handler];
        }
    }
}

- (void)success:(id)responseObjects {
    NSArray * arrayOfSuccessHandlers = nil;
    
    @synchronized(self) {
        if (MLLoadTokenStateReady != self.state) {
            return;
        }
        
        self.state = MLLoadTokenStateSuccess;
        arrayOfSuccessHandlers = [NSArray arrayWithArray:self.arrayOfSuccessHandlers];
        self.arrayOfSuccessHandlers = nil;
        self.arrayOfFailureHandlers = nil;
    }
    
    for (void(^handler)(id) in arrayOfSuccessHandlers) {
        handler(responseObjects);
    }
}

- (void)failure:(NSError *)error {
    NSArray * arrayOfFailureHandlers = nil;
    
    @synchronized(self) {
        if (MLLoadTokenStateReady != self.state) {
            return;
        }
        
        self.state = MLLoadTokenStateFailure;
        arrayOfFailureHandlers = [NSArray arrayWithArray:self.arrayOfFailureHandlers];
        self.arrayOfSuccessHandlers = nil;
        self.arrayOfFailureHandlers = nil;
    }
    
    for (void(^handler)(NSError *) in arrayOfFailureHandlers) {
        handler(error);
    }
}

- (void)ignore {
    @synchronized(self) {
        if (MLLoadTokenStateReady == self.state) {
            self.state = MLLoadTokenStateIgnore;
            self.arrayOfSuccessHandlers = nil;
            self.arrayOfFailureHandlers = nil;
        }
    }
}

@end
