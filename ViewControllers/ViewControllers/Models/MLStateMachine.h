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

#import <Foundation/Foundation.h>

extern NSString * const MLStateMachineStateNil;

@class MLStateMachine;

@protocol MLStateMachineDelegate <NSObject>

@optional
// Completely generic state change hook
- (void)stateMachineWillChangeState:(MLStateMachine *)stateMachine;
- (void)stateMachineDidChangeState:(MLStateMachine *)stateMachine;
- (void)stateMachine:(MLStateMachine *)stateMachine didChangeFromState:(NSString *)fromState toState:(NSString *)toState;

// Return the new state or nil for no change for an missing transition from a state to another state. If implemented, overrides the base implementation completely.
- (NSString *)missingTransitionFromState:(NSString *)fromState toState:(NSString *)toState;

// State machine also support calling the delegate (or subclasses) different selectors to handle state transitions:
// - (BOOL)shouldEnter[toState];
// - (void)didExit[fromState];
// - (void)didEnter[toState];
// - (void)stateDidChangeFrom[formState]To[toState];

@end

@interface MLStateMachine : NSObject

@property (atomic, readwrite, copy) NSString * currentState;
@property (atomic, readwrite, strong) NSDictionary * validTransitions;

// If set, MLStateMachine invokes transition methods on this delegate instead of self. This allows MLStateMachine to be used where subclassing doesn't make sense. The delegate is invoked on the same thread as -setCurrentState:
@property (atomic, readwrite, weak) id <MLStateMachineDelegate> delegate;

// Use NSLog to output state transitions; useful for debugging, but can be noisy
@property (nonatomic, readwrite, assign) BOOL shouldLogStateTransitions;

// Set current state and return YES if the state changed successfully to the supplied state, NO otherwise. Note that this does _not_ bypass missingTransitionFromState, so, if you invoke this, you must also supply an missingTransitionFromState implementation that avoids raising exceptions.
- (BOOL)applyState:(NSString *)state;

// For subclasses. Base implementation raises IllegalStateTransition exception. Need not invoke super unless desired. Should return the desired state if it doesn't raise, or nil for no change.
- (NSString *)missingTransitionFromState:(NSString *)fromState toState:(NSString *)toState;

@end
