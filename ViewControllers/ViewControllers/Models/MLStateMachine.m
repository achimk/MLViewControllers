//
//  MLStateMachine.m
//  ViewControllers
//
//  Created by Joachim Kret on 18.03.2015.
//  Copyright (c) 2015 Joachim Kret. All rights reserved.
//

#import "MLStateMachine.h"
#import <libkern/OSAtomic.h>
#import <objc/message.h>

#ifdef ENABLE_STATE_MACHINE_LOGGING
#define ENABLE_STATE_MACHINE_LOGGING    1
#endif

NSString * const MLStateMachineStateNil     = @"Nil";

#pragma mark - MLStateMachine

@interface MLStateMachine () {
    OSSpinLock _lock;
}

@end

#pragma mark -

@implementation MLStateMachine

@synthesize currentState = _currentState;

#pragma mark Init

- (instancetype)init {
    if (self = [super init]) {
        _lock = OS_SPINLOCK_INIT;
    }

    return self;
}

#pragma mark Accessors

- (id)target {
    return (self.delegate) ?: self;
}

- (void)setCurrentState:(NSString *)currentState {
    [self applyState:currentState];
}

- (NSString *)currentState {
    __block NSString * currentState = nil;
    
    OSSpinLockLock(&_lock);
    currentState = _currentState;
    OSSpinLockUnlock(&_lock);
    
    return currentState;
}

#pragma mark Change State

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
    
    OSSpinLockLock(&_lock);
    _currentState = [toState copy];
    OSSpinLockUnlock(&_lock);
    
    [self performTransitionFromState:fromState toState:toState];
    
    return [state isEqual:toState];
}

- (NSString *)missingTransitionFromState:(NSString *)fromState toState:(NSString *)toState {
    [NSException raise:@"IllegalStateTransition" format:@"cannot transition from %@ to %@", fromState, toState];
    return nil;
}

#pragma mark Private Methods

- (NSString *)stateTransitionFromState:(NSString *)fromState toState:(NSString *)toState {
    if ([_delegate respondsToSelector:@selector(missingTransitionFromState:toState:)]) {
        return [_delegate missingTransitionFromState:fromState toState:toState];
    }
    
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
    
    NSString * fromStateNotNil = (fromState) ?: MLStateMachineStateNil;
    SEL transitionSelector = NSSelectorFromString([NSString stringWithFormat:@"stateDidChangeFrom%@To%@", fromStateNotNil, toState]);
    if ([target respondsToSelector:transitionSelector]) {
        sendMsgReturnVoid(target, transitionSelector);
    }
    
    SEL didChangeSelector = @selector(stateDidChange);
    if ([target respondsToSelector:didChangeSelector]) {
        sendMsgReturnVoid(target, didChangeSelector);
    }
}

@end
