//
//  MLLoadToken.h
//  ViewControllers
//
//  Created by Joachim Kret on 22.03.2015.
//  Copyright (c) 2015 Joachim Kret. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, MLLoadTokenState) {
    MLLoadTokenStateReady,
    MLLoadTokenStateSuccess,
    MLLoadTokenStateFailure,
    MLLoadTokenStateIgnore
};

@interface MLLoadToken : NSObject

@property (nonatomic, readonly, assign) MLLoadTokenState state;

+ (instancetype)token;

- (void)addSuccessHandler:(void (^)(id responseObjects))handler;
- (void)addFailureHandler:(void (^)(NSError * error))handler;

- (void)success:(id)responseObjects;
- (void)failure:(NSError *)error;
- (void)ignore;

@end
