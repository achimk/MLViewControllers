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
@property (nonatomic, readwrite, strong) NSError * error;
@property (nonatomic, readwrite, strong) NSMutableArray * arrayOfSuccessHandlers;
@property (nonatomic, readwrite, strong) NSMutableArray * arrayOfFailureHandlers;
@property (nonatomic, readwrite, strong) NSMutableArray * arrayOfIgnoreHandlers;

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
        _arrayOfIgnoreHandlers = [[NSMutableArray alloc] init];
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

- (void)addIgnoreHandler:(void (^)(void))handler {
    NSParameterAssert(handler);
    
    @synchronized(self) {
        if (MLLoadTokenStateReady == self.state) {
            [self.arrayOfIgnoreHandlers addObject:handler];
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
        self.arrayOfIgnoreHandlers = nil;
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
        
        self.error = error;
        self.state = MLLoadTokenStateFailure;
        arrayOfFailureHandlers = [NSArray arrayWithArray:self.arrayOfFailureHandlers];
        self.arrayOfSuccessHandlers = nil;
        self.arrayOfFailureHandlers = nil;
        self.arrayOfIgnoreHandlers = nil;
    }
    
    for (void(^handler)(NSError *) in arrayOfFailureHandlers) {
        handler(error);
    }
}

- (void)ignore {
    NSArray * arrayOfIgnoreHandlers = nil;
    
    @synchronized(self) {
        if (MLLoadTokenStateReady != self.state) {
            return;
        }
        
        self.state = MLLoadTokenStateIgnore;
        arrayOfIgnoreHandlers = [NSArray arrayWithArray:self.arrayOfIgnoreHandlers];
        self.arrayOfSuccessHandlers = nil;
        self.arrayOfFailureHandlers = nil;
        self.arrayOfIgnoreHandlers = nil;
    }
    
    for (void(^handler)(void) in arrayOfIgnoreHandlers) {
        handler();
    }
}

@end
