//
//  MLLoadableContent.m
//  ViewControllers
//
//  Created by Joachim Kret on 22.03.2015.
//  Copyright (c) 2015 Joachim Kret. All rights reserved.
//

#import "MLLoadableContent.h"
#import <objc/message.h>

NSString * const MLContentStateInitial          = @"InitialState";
NSString * const MLContentStateLoading          = @"LoadingState";
NSString * const MLContentStateRefreshing       = @"RefreshingState";
NSString * const MLContentStatePaging           = @"PagingState";
NSString * const MLContentStateLoaded           = @"LoadedState";
NSString * const MLContentStateNoContent        = @"NoContentState";
NSString * const MLContentStateError            = @"ErrorState";

#pragma mark - MLLoadableContent

@interface MLLoadableContent ()

@property (nonatomic, readwrite, strong) MLLoadToken * loadToken;
@property (nonatomic, readonly, strong) NSDictionary * validTransitions;

- (BOOL)applyState:(NSString *)state;
- (NSString *)missingTransitionFromState:(NSString *)fromState toState:(NSString *)toState;

@end

#pragma mark -

@implementation MLLoadableContent

+ (NSDictionary *)defaultTransitions {
    return @{
             MLContentStateInitial     : @[MLContentStateLoading],
             MLContentStateLoading     : @[MLContentStateLoaded, MLContentStateNoContent, MLContentStateError],
             MLContentStateRefreshing  : @[MLContentStateLoaded, MLContentStateNoContent, MLContentStateError],
             MLContentStateLoaded      : @[MLContentStateRefreshing, MLContentStateNoContent, MLContentStateError],
             MLContentStateNoContent   : @[MLContentStateRefreshing, MLContentStateLoaded, MLContentStateError],
             MLContentStateError       : @[MLContentStateLoading, MLContentStateRefreshing, MLContentStateNoContent, MLContentStateLoaded]
             };
}

+ (NSDictionary *)pagingTransitions {
    return @{
             MLContentStateInitial     : @[MLContentStateLoading],
             MLContentStateLoading     : @[MLContentStateLoaded, MLContentStateNoContent, MLContentStateError],
             MLContentStateRefreshing  : @[MLContentStateLoaded, MLContentStateNoContent, MLContentStateError],
             MLContentStatePaging      : @[MLContentStateRefreshing, MLContentStateLoaded, MLContentStateNoContent, MLContentStateError],
             MLContentStateLoaded      : @[MLContentStateRefreshing, MLContentStatePaging, MLContentStateNoContent, MLContentStateError],
             MLContentStateNoContent   : @[MLContentStateRefreshing, MLContentStateLoaded, MLContentStateError],
             MLContentStateError       : @[MLContentStateLoading, MLContentStateRefreshing, MLContentStatePaging, MLContentStateNoContent, MLContentStateLoaded]
             };
}

#pragma mark Init / Dealloc

- (instancetype)init {
    return [self initWithType:MLLoadableContentTypeDefault];
}

- (instancetype)initWithType:(MLLoadableContentType)type {
    if (self = [super init]) {
        _type = type;
        _currentState = MLContentStateInitial;
        
        switch (type) {
            case MLLoadableContentTypeDefault: {
                _validTransitions = [[self class] defaultTransitions];
            } break;
            case MLLoadableContentTypePaging: {
                _validTransitions = [[self class] pagingTransitions];
            } break;
        }
    }
    
    return self;
}

- (void)dealloc {
    [self.loadToken ignore];
}

#pragma mark Content State

- (BOOL)loadContent {
    return [self loadContentWithState:MLContentStateLoading];
}

- (BOOL)refreshContent {
    return [self loadContentWithState:MLContentStateRefreshing];
}

- (BOOL)pageContent {
    return [self loadContentWithState:MLContentStatePaging];
}

- (BOOL)loadContentWithState:(NSString *)state {
    NSParameterAssert(state);
    NSAssert([state isEqualToString:MLContentStateRefreshing] ||
             [state isEqualToString:MLContentStateLoading] ||
             [state isEqualToString:MLContentStatePaging], @"Unsupported load content state: %@", state);
    
    BOOL applyState = [self applyState:state];
    
    if (applyState) {
        __weak typeof(self) weakSelf = self;
        MLLoadToken * token = [MLLoadToken token];
        [token addSuccessHandler:^(id responseObjects) {
            if (responseObjects) {
                [weakSelf applyState:MLContentStateLoaded];
            }
            else {
                [weakSelf applyState:MLContentStateNoContent];
            }
        }];
        [token addFailureHandler:^(NSError *error) {
            [weakSelf applyState:MLContentStateError];
        }];
        
        [self.loadToken ignore];
        self.loadToken = token;
     
        [self.delegate loadableContent:self loadDataWithLoadToken:token];
    }
    
    return applyState;
}

#pragma mark Subclass Methods

- (NSString *)missingTransitionFromState:(NSString *)fromState toState:(NSString *)toState {
    // Subclasses can override this method to provide missing state handling
    return nil;
}

#pragma mark Private Methods

- (BOOL)applyState:(NSString *)state {
    NSString * fromState = self.currentState;
    NSString * toState = [self validateTransitionFromState:fromState toState:state];
    
    if (!toState) {
        return NO;
    }
    
    if ([self.delegate respondsToSelector:@selector(loadableContentWillChangeState:)]) {
        [self.delegate loadableContentWillChangeState:self];
    }
    
    _currentState = [toState copy];
    
    [self performTransitionFromState:fromState toState:toState];
    
    return [state isEqualToString:toState];
}

- (NSString *)validateTransitionFromState:(NSString *)fromState toState:(NSString *)toState {
    if (!toState) {
        toState = [self missingTransitionFromState:fromState toState:toState];
        if (!toState) {
            return nil;
        }
    }
    
    if (fromState) {
        id validTransitions = self.validTransitions[fromState];
        BOOL transitionSpecified = YES;
        
        if ([validTransitions isKindOfClass:[NSArray class]]) {
            if (![validTransitions containsObject:toState]) {
                transitionSpecified = NO;
            }
        }
        else if (![validTransitions isEqual:toState]) {
            transitionSpecified = NO;
        }
        
        if (!transitionSpecified) {
            if ([fromState isEqualToString:toState]) {
                return nil;
            }
            
            toState = [self missingTransitionFromState:fromState toState:toState];
            if (!toState) {
                return nil;
            }
        }
    }
    
    typedef BOOL (*ObjCMsgSendReturnBool)(id, SEL);
    ObjCMsgSendReturnBool sendMsgReturnBool = (ObjCMsgSendReturnBool)objc_msgSend;
    
    SEL selector = NSSelectorFromString([@"loadableContentShouldEnter" stringByAppendingString:toState]);
    if ([self.delegate respondsToSelector:selector] && !sendMsgReturnBool(self.delegate, selector)) {
        toState = [self missingTransitionFromState:fromState toState:toState];
    }
    
    return toState;
}

- (void)performTransitionFromState:(NSString *)fromState toState:(NSString *)toState {
    NSParameterAssert(toState);
    
    typedef void (*ObjCMsgSendReturnVoid)(id, SEL);
    ObjCMsgSendReturnVoid sendMsgReturnVoid = (ObjCMsgSendReturnVoid)objc_msgSend;
    
    if (fromState) {
        SEL exitSelector = NSSelectorFromString([@"loadableContentDidExit" stringByAppendingString:fromState]);
        if ([self.delegate respondsToSelector:exitSelector]) {
            sendMsgReturnVoid(self.delegate, exitSelector);
        }
    }
    
    SEL enterSelector = NSSelectorFromString([@"loadableContentDidEnter" stringByAppendingString:toState]);
    if ([self.delegate respondsToSelector:enterSelector]) {
        sendMsgReturnVoid(self.delegate, enterSelector);
    }
    
    SEL transitionSelector = NSSelectorFromString([NSString stringWithFormat:@"loadableContentStateDidChangeFrom%@To%@", fromState, toState]);
    if ([self.delegate respondsToSelector:transitionSelector]) {
        sendMsgReturnVoid(self.delegate, transitionSelector);
    }
    
    if ([self.delegate respondsToSelector:@selector(loadableContentDidChangeState:)]) {
        [self.delegate loadableContentDidChangeState:self];
    }
}

@end
