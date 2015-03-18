//
//  MLDataSourceStateMachine.m
//  ViewControllers
//
//  Created by Joachim Kret on 18.03.2015.
//  Copyright (c) 2015 Joachim Kret. All rights reserved.
//

#import "MLDataSourceStateMachine.h"

NSString * const MLDataSourceStateInitial       = @"InitialState";
NSString * const MLDataSourceStateLoading       = @"LoadingState";
NSString * const MLDataSourceStateRefreshing    = @"RefreshingState";
NSString * const MLDataSourceStateLoaded        = @"LoadedState";
NSString * const MLDataSourceStateNoContent     = @"NoContentState";
NSString * const MLDataSourceStateError         = @"ErrorState";

@implementation MLDataSourceStateMachine

#pragma mark Init

- (instancetype)init {
    if (self = [super init]) {
        self.currentState = MLDataSourceStateInitial;
        self.validTransitions = @{
                                  MLDataSourceStateInitial      : @[MLDataSourceStateLoading],
                                  MLDataSourceStateLoading      : @[MLDataSourceStateLoaded, MLDataSourceStateNoContent, MLDataSourceStateError],
                                  MLDataSourceStateRefreshing   : @[MLDataSourceStateLoaded, MLDataSourceStateNoContent, MLDataSourceStateError],
                                  MLDataSourceStateLoaded       : @[MLDataSourceStateRefreshing, MLDataSourceStateNoContent, MLDataSourceStateError],
                                  MLDataSourceStateNoContent    : @[MLDataSourceStateRefreshing, MLDataSourceStateLoaded, MLDataSourceStateError],
                                  MLDataSourceStateError        : @[MLDataSourceStateLoading, MLDataSourceStateRefreshing, MLDataSourceStateNoContent, MLDataSourceStateLoaded]
                                  };
    }
    
    return self;
}

@end
