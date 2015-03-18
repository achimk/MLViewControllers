//
//  MLStateMachine.h
//  ViewControllers
//
//  Created by Joachim Kret on 18.03.2015.
//  Copyright (c) 2015 Joachim Kret. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const MLStateMachineStateNil;

@protocol MLStateMachineDelegate <NSObject>

@optional
// Completely generic state change hook
- (void)stateWillChange;
- (void)stateDidChange;

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

// If set, MLStateMachine invokes transition methods on this delegate instead of self. This allows AAPLStateMachine to be used where subclassing doesn't make sense. The delegate is invoked on the same thread as -setCurrentState:
@property (atomic, readwrite, weak) id <MLStateMachineDelegate> delegate;

// Use NSLog to output state transitions; useful for debugging, but can be noisy
@property (nonatomic, readwrite, assign) BOOL shouldLogStateTransitions;

// Set current state and return YES if the state changed successfully to the supplied state, NO otherwise. Note that this does _not_ bypass missingTransitionFromState, so, if you invoke this, you must also supply an missingTransitionFromState implementation that avoids raising exceptions.
- (BOOL)applyState:(NSString *)state;

// For subclasses. Base implementation raises IllegalStateTransition exception. Need not invoke super unless desired. Should return the desired state if it doesn't raise, or nil for no change.
- (NSString *)missingTransitionFromState:(NSString *)fromState toState:(NSString *)toState;

@end
