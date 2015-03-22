//
//  MLLoadableContentViewModel.h
//  ViewControllers
//
//  Created by Joachim Kret on 22.03.2015.
//  Copyright (c) 2015 Joachim Kret. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MLLoadToken.h"

extern NSString * const MLContentStateInitial;
extern NSString * const MLContentStateLoading;
extern NSString * const MLContentStateRefreshing;
extern NSString * const MLContentStatePaging;
extern NSString * const MLContentStateLoaded;
extern NSString * const MLContentStateNoContent;
extern NSString * const MLContentStateError;

@class MLLoadableContentViewModel;

@protocol MLLoadableContentDelegate <NSObject>

#warning Change optional delegate methods!
@optional
- (void)loadableContent:(MLLoadableContentViewModel *)model loadDataWithLoadToken:(MLLoadToken *)loadToken;

// Completely generic state change
- (void)stateWillChange;
- (void)stateDidChange;
//- (void)loadableContentWillChangeState:(MLLoadableContentViewModel *)model;
//- (void)loadableContentDidChangeState:(MLLoadableContentViewModel *)model;

// State machine also support calling the delegate (or subclasses) different selectors to handle state transitions:
// - (BOOL)shouldEnter[toState];
// - (void)didExit[fromState];
// - (void)didEnter[toState];
// - (void)stateDidChangeFrom[formState]To[toState];

@end

@interface MLLoadableContentViewModel : NSObject

@property (nonatomic, readonly, copy) NSString * currentState;
@property (nonatomic, readonly, strong) NSDictionary * validTransitions;
@property (nonatomic, readonly, strong) MLLoadToken * loadToken;
@property (nonatomic, readonly, strong) NSError * error;

@property (nonatomic, readwrite, weak) id <MLLoadableContentDelegate> delegate;
@property (nonatomic, readwrite, assign) BOOL shouldLogStateTransitions;

- (BOOL)loadContent;
- (BOOL)refreshContent;
- (BOOL)pageContent;

@end

@interface MLLoadableContentViewModel (MLSubclassOnly)

- (void)loadDataWithLoadToken:(MLLoadToken *)loadToken;
- (NSString *)missingTransitionFromState:(NSString *)fromState toState:(NSString *)toState;

@end
