//  Sample code project: Advanced User Interfaces Using Collection View
//  Version: 1.0
//
//  IMPORTANT:  This Apple software is supplied to you by Apple
//  Inc. ("Apple") in consideration of your agreement to the following
//  terms, and your use, installation, modification or redistribution of
//  this Apple software constitutes acceptance of these terms.  If you do
//  not agree with these terms, please do not use, install, modify or
//  redistribute this Apple software.
//
//  In consideration of your agreement to abide by the following terms, and
//  subject to these terms, Apple grants you a personal, non-exclusive
//  license, under Apple's copyrights in this original Apple software (the
//  "Apple Software"), to use, reproduce, modify and redistribute the Apple
//  Software, with or without modifications, in source and/or binary forms;
//  provided that if you redistribute the Apple Software in its entirety and
//  without modifications, you must retain this notice and the following
//  text and disclaimers in all such redistributions of the Apple Software.
//  Neither the name, trademarks, service marks or logos of Apple Inc. may
//  be used to endorse or promote products derived from the Apple Software
//  without specific prior written permission from Apple.  Except as
//  expressly stated in this notice, no other rights or licenses, express or
//  implied, are granted by Apple herein, including but not limited to any
//  patent rights that may be infringed by your derivative works or by other
//  works in which the Apple Software may be incorporated.
//
//  The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
//  MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
//  THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
//  FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
//  OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
//
//  IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
//  OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
//  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
//  INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
//  MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
//  AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
//  STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
//  POSSIBILITY OF SUCH DAMAGE.
//
//  Copyright (C) 2014 Apple Inc. All Rights Reserved.
//
//  Created by Joachim Kret on 18.03.2015.
//  Copyright (c) 2015 Joachim Kret. All rights reserved.
//

#import "MLStateMachine.h"
#import <libkern/OSAtomic.h>
#import <objc/message.h>

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

#pragma mark State

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
    SEL willChangeSelector = @selector(stateMachineWillChangeState:);
    if ([target respondsToSelector:willChangeSelector]) {
        typedef void (*ObjCMsgSendSelfReturnVoid)(id, SEL, MLStateMachine *);
        ObjCMsgSendSelfReturnVoid sendSelfMsgReturnVoid = (ObjCMsgSendSelfReturnVoid)objc_msgSend;
        sendSelfMsgReturnVoid(target, willChangeSelector, self);
    }
    
    OSSpinLockLock(&_lock);
    _currentState = [toState copy];
    OSSpinLockUnlock(&_lock);
    
    [self performTransitionFromState:fromState toState:toState];
    
    return [state isEqualToString:toState];
}

- (BOOL)canApplyState:(NSString *)state {
    NSString * fromState = self.currentState;
    NSString * toState = [self validateTransitionFromState:fromState toState:state];
    
    return ([state isEqualToString:toState]);
}

- (NSString *)missingTransitionFromState:(NSString *)fromState toState:(NSString *)toState {
    NSAssert2(NO, @"State machine cannot transit from %@ to %@", fromState, toState);
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
    
    SEL didChangeSelector = @selector(stateMachineDidChangeState:);
    if ([target respondsToSelector:didChangeSelector]) {
        typedef void (*ObjCMsgSendSelfReturnVoid)(id, SEL, MLStateMachine *);
        ObjCMsgSendSelfReturnVoid sendSelfMsgReturnVoid = (ObjCMsgSendSelfReturnVoid)objc_msgSend;
        sendSelfMsgReturnVoid(target, didChangeSelector, self);
    }
}

@end
