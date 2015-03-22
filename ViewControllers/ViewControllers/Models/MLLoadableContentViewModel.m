//
//  MLLoadableContentViewModel.m
//  ViewControllers
//
//  Created by Joachim Kret on 22.03.2015.
//  Copyright (c) 2015 Joachim Kret. All rights reserved.
//

#import "MLLoadableContentViewModel.h"
#import <objc/message.h>

NSString * const MLContentStateNil              = @"Nil";
NSString * const MLContentStateInitial          = @"InitialState";
NSString * const MLContentStateLoading          = @"LoadingState";
NSString * const MLContentStateRefreshing       = @"RefreshingState";
NSString * const MLContentStatePaging           = @"PagingState";
NSString * const MLContentStateLoaded           = @"LoadedState";
NSString * const MLContentStateNoContent        = @"NoContentState";
NSString * const MLContentStateError            = @"ErrorState";

#pragma mark - MLLoadableContentViewModel

@interface MLLoadableContentViewModel ()

@property (nonatomic, readwrite, strong) MLLoadToken * loadToken;
@property (nonatomic, readwrite, strong) NSError * error;

- (BOOL)applyState:(NSString *)state;
- (NSString *)missingTransitionFromState:(NSString *)fromState toState:(NSString *)toState;

@end

#pragma mark -

@implementation MLLoadableContentViewModel

- (instancetype)init {
    if (self = [super init]) {
        _currentState = MLContentStateInitial;
        _validTransitions = @{
                              MLContentStateInitial     : @[MLContentStateLoading],
                              MLContentStateLoading     : @[MLContentStateLoaded, MLContentStateNoContent, MLContentStateError],
                              MLContentStateRefreshing  : @[MLContentStateLoaded, MLContentStateNoContent, MLContentStateError],
                              MLContentStatePaging      : @[MLContentStateRefreshing, MLContentStateLoaded, MLContentStateNoContent, MLContentStateError],
                              MLContentStateLoaded      : @[MLContentStateRefreshing, MLContentStatePaging, MLContentStateNoContent, MLContentStateError],
                              MLContentStateNoContent   : @[MLContentStateRefreshing, MLContentStateLoaded, MLContentStateError],
                              MLContentStateError       : @[MLContentStateLoading, MLContentStateRefreshing, MLContentStatePaging, MLContentStateNoContent, MLContentStateLoaded]
                              };
    }
    
    return self;
}

#pragma mark Accessors

- (id)target {
    return (self.delegate) ?: self;
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
            weakSelf.error = error;
            [weakSelf applyState:MLContentStateError];
        }];
        
        [self.loadToken ignore];
        self.loadToken = token;
        
        if ([self.delegate respondsToSelector:@selector(loadableContent:loadDataWithLoadToken:)]) {
            [self.delegate loadableContent:self loadDataWithLoadToken:token];
        }
        else {
            [self loadDataWithLoadToken:token];
        }
    }
    
    return applyState;
}

#pragma mark Subclass Methods

- (void)loadDataWithLoadToken:(MLLoadToken *)loadToken {
    [NSException raise:NSInternalInconsistencyException format:@"You must override %@ in subclass.", NSStringFromSelector(_cmd)];
}

- (NSString *)missingTransitionFromState:(NSString *)fromState toState:(NSString *)toState {
    [NSException raise:NSInternalInconsistencyException format:@"Cannot transition from %@ to %@", fromState, toState];
    return nil;
}

#pragma mark Private Methods

- (BOOL)applyState:(NSString *)state {
    NSString * fromState = self.currentState;
    
    if (self.shouldLogStateTransitions) {
        NSLog(@"%@ -> request state change from %@ to %@", [self class], fromState, state);
    }
    
    NSString * toState = [self validateTransitionFromState:fromState toState:state];
    
    if (!toState) {
        return NO;
    }
    
    id target = self.target;
    SEL willChangeSelector = @selector(stateWillChange);
    if ([target respondsToSelector:willChangeSelector]) {
        typedef void (*ObjCMsgSendReturnVoid)(id, SEL);
        ObjCMsgSendReturnVoid sendMsgReturnVoid = (ObjCMsgSendReturnVoid)objc_msgSend;
        sendMsgReturnVoid(target, willChangeSelector);
    }
    
    _currentState = [toState copy];
    
    [self performTransitionFromState:fromState toState:toState];
    
    return [state isEqualToString:toState];
}

- (BOOL)canApplyState:(NSString *)state {
    NSString * fromState = self.currentState;
    NSString * toState = [self validateTransitionFromState:fromState toState:state];
    
    return ([state isEqualToString:toState]);
}

- (NSString *)stateTransitionFromState:(NSString *)fromState toState:(NSString *)toState {
    return [self missingTransitionFromState:fromState toState:toState];
}

- (NSString *)validateTransitionFromState:(NSString *)fromState toState:(NSString *)toState {
    if (!toState) {
        if (self.shouldLogStateTransitions) {
            NSLog(@"%@ -> cannot transition to <nil> state", [self class]);
        }
        
        toState = [self stateTransitionFromState:fromState toState:toState];
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
                if (self.shouldLogStateTransitions) {
                    NSLog(@"%@ -> ignoring reentry to %@", [self class], toState);
                }
                
                return nil;
            }
            
            if (self.shouldLogStateTransitions) {
                NSLog(@"%@ -> annot transition to %@ from %@", [self class], toState, fromState);
            }
            
            toState = [self stateTransitionFromState:fromState toState:toState];
            if (!toState) {
                return nil;
            }
        }
    }
    
    id target = self.target;
    typedef BOOL (*ObjCMsgSendReturnBool)(id, SEL);
    ObjCMsgSendReturnBool sendMsgReturnBool = (ObjCMsgSendReturnBool)objc_msgSend;
    
    SEL selector = NSSelectorFromString([@"shouldEnter" stringByAppendingString:toState]);
    if ([target respondsToSelector:selector] && !sendMsgReturnBool(target, selector)) {
        if (self.shouldLogStateTransitions) {
            NSLog(@"%@ -> transition disallowed to %@ from %@ (via %@)", [self class], toState, fromState, NSStringFromSelector(selector));
        }
        
        toState = [self stateTransitionFromState:fromState toState:toState];
    }
    
    return toState;
}

- (void)performTransitionFromState:(NSString *)fromState toState:(NSString *)toState {
    NSParameterAssert(toState);
    
    if (self.shouldLogStateTransitions) {
        NSLog(@"%@ -> state change from %@ to %@", [self class], fromState, toState);
    }
    
    id target = self.target;
    typedef void (*ObjCMsgSendReturnVoid)(id, SEL);
    ObjCMsgSendReturnVoid sendMsgReturnVoid = (ObjCMsgSendReturnVoid)objc_msgSend;
    
    if (fromState) {
        SEL exitSelector = NSSelectorFromString([@"didExit" stringByAppendingString:fromState]);
        if ([target respondsToSelector:exitSelector]) {
            sendMsgReturnVoid(target, exitSelector);
        }
    }
    
    SEL enterSelector = NSSelectorFromString([@"didEnter" stringByAppendingString:toState]);
    if ([target respondsToSelector:enterSelector]) {
        sendMsgReturnVoid(target, enterSelector);
    }
    
    SEL transitionSelector = NSSelectorFromString([NSString stringWithFormat:@"stateDidChangeFrom%@To%@", fromState, toState]);
    if ([target respondsToSelector:transitionSelector]) {
        sendMsgReturnVoid(target, transitionSelector);
    }
    
    SEL didChangeSelector = @selector(stateDidChange);
    if ([target respondsToSelector:didChangeSelector]) {
        sendMsgReturnVoid(target, didChangeSelector);
    }
}

@end
